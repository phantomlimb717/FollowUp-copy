//
//  InteractionManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 25/06/2025.
//

import Foundation

class InteractionManager: ObservableObject {
    
    // MARK: - Stored Properties
    private var contactsInteractor: ContactsInteracting
    @Published public var pendingInteractions: [PendingInteraction]
    public var lastInteraction: PendingInteraction? { self.pendingInteractions.last }
    
    // MARK: - Initializer
    init(contactsInteractor: ContactsInteracting, pendingInteractions: [PendingInteraction] = []) {
        self.contactsInteractor = contactsInteractor
        self.pendingInteractions = pendingInteractions
    }
    
    // MARK: - Functions
    func beginInteraction(type: InteractionType, with contact: any Contactable) {
        let pendingInteraction: PendingInteraction = .init(type: type, contactId: contact.id, contactName: contact.firstName, date: .now)
        guard !self.pendingInteractions.contains(pendingInteraction) else {
            Log.warn("Tried to add pending interaction which already exists in queue: \(pendingInteraction)")
            return
        }
        Log.info("Added pending \(type.title) interaction for \(contact.name). Awaiting confirmation.")
        self.pendingInteractions.append(pendingInteraction)
    }
    
    func confirm(_ interaction: PendingInteraction, onComplete: (() -> Void)? = nil){
        
        guard self.pendingInteractions.contains(interaction) else {
            Log.warn("Tried to confirm interaction which is not pending: \(interaction)")
            return
        }
        
        // Remove it from the array if it exists, and convert it into a timeline item.
        self.pendingInteractions.removeAll(where: { $0 == interaction })
        
        // Add it as a timeline item.
        self.contactsInteractor.add(item: .init(interaction), toContactID: interaction.contactId, onComplete: {
            Log.info("Confirmed interaction \(interaction) and added to ContactTimeline.")
            onComplete?()
        })
    }
    
    func dismiss(_ interaction: PendingInteraction) {
        guard self.pendingInteractions.contains(interaction) else {
            Log.warn("Tried to dismiss interaction which is not pending: \(interaction)")
            return
        }
        self.pendingInteractions.removeAll(where: { $0 == interaction })
        Log.info("Dismissed interaction \(interaction).")
    }
}
