//
//  ContactTimelineView.swift
//  FollowUp
//
//  Created by Aaron Baw on 24/03/2025.
//

import RealmSwift
import SwiftUI

struct ContactTimelineView: View {
    
    // MARK: - Stored Properties
    @State var newCommentText: String = ""
    @State var items: [TimelineItem] = []
    @State private var editingItem: TimelineItem?
    @State private var notificationToken: NotificationToken?
    @FocusState var commentInputActive: Bool
    @EnvironmentObject var followUpManager: FollowUpManager
    var contactsInteractor: ContactsInteracting { followUpManager.contactsInteractor }
    
    var contact: any Contactable
    
    var addCommentButton: some View {
        TextField("Add Comment", text: $newCommentText, prompt: Text("\(Image(icon: .bubble)) Add Comment"))
        .foregroundStyle(.secondary)
        .padding(.horizontal, Constant.ContactTimeline.commentBoxHorizontalPadding)
        .padding(.vertical, Constant.ContactTimeline.commentBoxVerticalPadding)
        .focused($commentInputActive)
        .background(
            RoundedRectangle(cornerRadius: Constant.ContactTimeline.cornerRadius)
                .stroke(.quaternary)
        )
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    self.newCommentText = ""
                    self.commentInputActive = false
                }
            }
        }
        .submitLabel(.go)
        .onSubmit {
            self.submitComment()
            self.newCommentText = ""
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 0) {
            
            ForEach(items.filter { !$0.isInvalidated }) { item in
                if items.first?.id != item.id {
                    VerticalDivider()
                }
                TimelineItemView(
                    item: item,
                    onEdit: { self.beginEditing(item: item) },
                    onDelete: { self.delete(item: item) }
                )
                
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                if items.last?.id != item.id {
                    VerticalDivider()
                }
            }
            
            addCommentButton
                .padding(.top)
        }.onAppear {
            self.items = Array(contact.timelineItems)
            self.observeChanges()
        }
        .animation(.easeInOut, value: self.items)
    }
    
    // MARK: - Functions
    func observeChanges() {
        // Set up Realm observation
        self.notificationToken = contact.timelineItems.observe { change in
            switch change {
            case .initial(let collection):
                self.items = Array(collection)
            case .update(let collection, _, _, _):
                withAnimation {
                    self.items = Array(collection)
                }
            case .error(let error):
                print("Error observing timelineItems: \(error)")
            }
        }
    }
    
    func submitComment() {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let editingItem = editingItem {
            self.contactsInteractor.edit(
                item: editingItem,
                newBodyText: self.newCommentText,
                for: contact, onComplete: nil
            )
            
        } else {
            let timelineItem = TimelineItem.comment(body: newCommentText)
            self.contactsInteractor.add(item: timelineItem, to: contact, onComplete: nil)
        }
        self.newCommentText = ""
    }
    
    func beginEditing(item: TimelineItem) {
        self.newCommentText = item.body ?? ""
        self.commentInputActive = true
        self.editingItem = item
    }
    
    func delete(item: TimelineItem){
        self.contactsInteractor.delete(item: item, for: contact, onComplete: nil)
    }
    
}

#if DEBUG
extension ContactTimelineView {
    init(items: [TimelineItem]) {
        self.contact = MockedContact()
        self.contact.timelineItems.append(objectsIn: items)
//        self._items = .init(initialValue: Array(contact.timelineItems))
    }
}

#endif

#Preview {
    let followUpManager = FollowUpManager.mocked()
    ContactTimelineView(items: [
        .mockedBT,
        .mockedCall,
        .mockedBirthday
    ])
        .padding()
        .environmentObject(followUpManager)
//        .environmentObject(followUpManager.store)
//        .environmentObject(FollowUpSettings())
}
