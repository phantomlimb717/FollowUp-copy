//
//  ContactSheetView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI
import RealmSwift

struct ContactSheetView: View {
    
    // MARK: - Environment
    @EnvironmentObject var store: FollowUpStore
    @EnvironmentObject var followUpManager: FollowUpManager
    var contactsInteractor: ContactsInteracting { followUpManager.contactsInteractor }

    // MARK: - Enums
    enum Kind {
        case modal
        case inline
    }

    // MARK: - Stored Properties
    var kind: Kind
    var sheet: ContactSheet
    var onClose: () -> Void
    var verticalSpacing: CGFloat = Constant.ContactSheet.verticalSpacing
    
    // MARK: - State
    @State private var nativeContactSheetID: String?
    
    // MARK: - Computed Properties
    private var relativeTimeSinceFollowingUp: String {
        guard let lastFollowedUpDate = contact.lastFollowedUp else { return "Never" }
        return Constant.relativeDateTimeFormatter
            .localizedString(
                for: lastFollowedUpDate,
                   relativeTo: .now
            )
    }
    

    private var contact: any Contactable {
        store.contact(forID: sheet.contactID) ?? Contact.unknown
    }
    
    // MARK: - Views
    @ViewBuilder
    private var contactBadgeAndNameView: some View {
        BadgeView(
            name: contact.name,
            image: contact.thumbnailImage,
            size: .large
        )
        Text(contact.name)
            .font(.largeTitle)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var contactButtons: some View {
        VStack {
            if let phoneNumber = contact.phoneNumber {
                Text(phoneNumber.value)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                HStack {
                    CircularButton(icon: .phone, action: .call(number: phoneNumber))
                    CircularButton(icon: .sms, action: .sms(number: phoneNumber))
                    CircularButton(icon: .whatsApp, action: .whatsApp(number: phoneNumber, generateText: { completion in completion(.success("")) }))
                    CircularButton(icon: .pencil, action: .other(action: {
                        displayNativeContactModal(forID: contact.id)
                    }))
                }
            }
        }
    }

    @ViewBuilder
    private var followUpDetailsView: some View {
        HStack(spacing: 20) {
            Label("\(contact.followUps)", systemImage: Constant.Icon.thumbsUp.rawValue)
            Label(relativeTimeSinceFollowingUp, systemImage: Constant.Icon.personWithClock.rawValue)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    // TODO: Refactor this out into a separate view.
    @ViewBuilder
    private var startAConversationRowView: some View {
        if (contact.phoneNumber) != nil {
            VStack(alignment: .leading, spacing: verticalSpacing) {
                Text("\(Image(icon: .chatWithWaveform)) Conversation Starters")
                    .foregroundStyle(.secondary)
                    .font(.body.weight(.medium))
                    .padding(.horizontal)
                ConversationStarterRowView(contact: contact)
            }
        }
    }
    
    private var tagsView: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            Text("\(Image(icon: .tag)) Tags")
                .padding(.horizontal)
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
            TagsCarouselView(contact: contact)
        }
    }
    
    private var closeButtonView: some View {
        HStack {
            Spacer()
            CloseButton(onClose: onClose)
                .padding([.top, .trailing])
        }
    }
    
    private var contactHeaderView: some View {
        VStack(spacing: verticalSpacing) {
            
            contactBadgeAndNameView
            DateMetView(contact: contact)
            followUpDetailsView
            
            if let note = contact.note, !note.isEmpty {
                ContactNoteView(note: note)
                    .animation(.easeInOut, value: contact.note)
            }
            
            contactButtons
            
        }.padding(.top, 50)
    }

    @ViewBuilder
    var timelineView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(Image(icon: .clock)) Timeline")
                .padding(.horizontal)
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
            ContactTimelineView(items: BubbleTimelineItem.mockedItems).padding()
        }
    }
    
    var blurView: some View {
        ZStack {
            Color.black // dark tint to reduce brightness
            
            Rectangle()
                .fill(Material.regularMaterial)
        }
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.black, .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .allowsHitTesting(false)
        .frame(height: 170)
    }
    
    var modalContactSheetView: some View {
        NavigationView {
            
            ZStack(alignment: .top) {

                ScrollView(.vertical) {
                    VStack(spacing: verticalSpacing) {
                        Spacer()
                        contactHeaderView
                        Spacer()
                        tagsView
                        Spacer()
                        startAConversationRowView
                        Spacer()
                        timelineView
                        
                        Spacer(minLength: 120)
                        
                    }
                }
                
                VStack {
                    Spacer()
                    blurView
                }.ignoresSafeArea()

                // Overlay View
                VStack {
                    closeButtonView
                    Spacer()
                    ActionButtonGridView(contact: contact)
                        .padding()
                }
            }
        }
    }
    
    private var inlineContactSheetView: some View {
        VStack(spacing: verticalSpacing) {
            contactBadgeAndNameView
            
            DateMetView(contact: contact)
            
            contactButtons
                .padding(.top)
            ActionButtonGridView(contact: contact, background: .clear)
                .padding([.top, .horizontal])
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constant.cornerRadius)
    }
    
    @ViewBuilder
    private var variableContent: some View {
        switch kind {
        case .modal: modalContactSheetView
        case .inline: inlineContactSheetView
        }
    }

    var body: some View {
        variableContent
            .sheet(item: $nativeContactSheetID, onDismiss: {
               
                // When the user does not edit the contact using 'Edit', the sheet appears to dismiss before the change to the contact is actually applied. We add a small delay to ensure the change is made so that the newly fetched contact contains the newest data.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.updateCurrentContact()
                })
            }, content: {_ in
                NativeContactView(contactID: contact.id)
                    .ignoresSafeArea(.all, edges: .bottom)
            })
    }
    
    // MARK: - Functions
    private func displayNativeContactModal(forID ID: String) {
        self.nativeContactSheetID = ID
    }
    
    private func updateCurrentContact() {
        followUpManager.contactsInteractor.updateContactInStore(withCNContactID: contact.id)
    }
    
}

#Preview {
    let followUpManager = FollowUpManager.mocked()

    Group {
        ContactSheetView(kind: .modal, sheet: MockedContact(
            id: "1",
            note: "Met on the underground at Euston Station. Works at a local hedgefund and is into cryptocurrency. Open to coming out, but is quite busy."
        ).sheet, onClose: { })

//        ContactSheetView(kind: .inline, sheet: MockedContact(id: "0").sheet, onClose: { })
//
//        ContactSheetView(kind: .modal, sheet: MockedContact(id: "0").sheet, onClose: { })
//            .preferredColorScheme(.dark)
    }
    .environmentObject(followUpManager)
    .environmentObject(followUpManager.store)
    .environmentObject(FollowUpSettings())
}

