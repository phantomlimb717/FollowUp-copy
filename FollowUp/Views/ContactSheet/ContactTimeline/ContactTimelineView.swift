//
//  ContactTimelineView.swift
//  FollowUp
//
//  Created by Aaron Baw on 24/03/2025.
//

import SwiftUI

struct ContactTimelineView: View {
    
    // MARK: - Stored Properties
    @State var newCommentText: String = ""
    @State private var editingItem: TimelineItem?
    @FocusState var commentInputActive: Bool
    @EnvironmentObject var followUpManager: FollowUpManager
    var contactsInteractor: ContactsInteracting { followUpManager.contactsInteractor }
    
    var contact: any Contactable
    
    // MARK: - Computed Properties
    @State var items: [TimelineItem] = []
    
    var verticalDivider: some View {
        HStack {
            Rectangle()
                .frame(width: 3, height: 10)
                .foregroundStyle(.quinary)
        }
    }
    
    var addCommentButton: some View {
        TextField("Add Comment", text: $newCommentText, prompt: Text("\(Image(icon: .bubble)) Add Comment"))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
            
            ForEach(items, id: \.id) { item in
                if items.first?.id != item.id {
                    verticalDivider
                }
                TimelineItemView(
                    item: item,
                    onEdit: { self.beginEditing(item: item) },
                    onDelete: { self.delete(item: item) }
                )
                if items.last?.id != item.id {
                    verticalDivider
                }
            }
            
            addCommentButton
                .padding(.top)
        }.onAppear {
            self.items = Array(contact.timelineItems)
        }
    }
    
    // MARK: - Functions
    func submitComment() {

        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let editingItem = editingItem {
            self.contactsInteractor.edit(
                item: editingItem,
                newBodyText: self.newCommentText,
                for: contact,
                onComplete: {
                    self.editingItem = nil
                    withAnimation {
                        self.items = Array(contact.timelineItems)
                    }
                }
            )
            
        } else {
            let timelineItem = TimelineItem.comment(body: newCommentText)
            self.contactsInteractor.add(item: timelineItem, to: contact, onComplete: {
                withAnimation {
                    self.items = Array(contact.timelineItems)
                }
            })
        }
        self.newCommentText = ""
    }
    
    func beginEditing(item: TimelineItem) {
        self.newCommentText = item.body ?? ""
        self.commentInputActive = true
        self.editingItem = item
    }
    
    func delete(item: TimelineItem){
        // We remove the item first from the UI Hierarchy to prevent errors when the item is removed from Realm.
        withAnimation {
            self.items.removeAll(where: { item == $0 })
        }
        self.contactsInteractor.delete(item: item, for: contact, onComplete: {
            withAnimation {
                self.items.removeAll(where: { item == $0 })
            }
        })
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
