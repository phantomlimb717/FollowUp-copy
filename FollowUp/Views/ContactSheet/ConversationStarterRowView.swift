//
//  ConversationStarterRowView.swift
//  FollowUp
//
//  Created by Aaron Baw on 24/10/2024.
//

import SwiftUI

struct ConversationStarterRowView: View {
    
    // MARK: - View Properties
    var contact: any Contactable
    @State private var conversationStarters: [ConversationStarterTemplate] = []
    @State private var draggingConversationStarter: ConversationStarterTemplate? = nil
    @State private var editingConversationStarter: ConversationStarterTemplate? = nil
    
    // MARK: - Environment Objects
    @EnvironmentObject var settings: FollowUpSettings
    
    // MARK: - Constants
    private var verticalSpacing: CGFloat { Constant.ContactSheet.verticalSpacing }
    
    // Add button for conversation starters
    private var addConversationStarterButton: some View {
        Menu(content: {
            Button(action: {
                self.addStandardConversationStarter()
            }, label: {
                Label(title: { Text("Standard") }, icon:  { Image(icon: .chatWithElipses) })
            })
            Button(action: {
                self.addIntelligentConversationStarter()
            }, label: {
                Label(title: { Text("AI") }, icon:  { Image(icon: .chatWithWaveform) })
            })
        }, label: {
            Image(icon: .plus)
        })
        .roundedIconButtonStyle()
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(conversationStarters) { conversationStarter in
                    ConversationActionButtonView(template: conversationStarter, contact: contact)
                        .onDrag {
                            self.draggingConversationStarter = conversationStarter
                            return NSItemProvider(object: String(conversationStarter.id) as NSString) // Use the `id` or unique identifier of your `Tag`
                        }
                        .onDrop(
                            of: [.plainText],
                            delegate:
                                DragRelocateDelegate(
                                    item: conversationStarter,
                                    localConvoStarters: $conversationStarters,
                                    currentlyDraggedItem: $draggingConversationStarter,
                                    commitChangesClosure: commitConversationStarterChanges
                                )
                        )
                        .transition(.opacity)
                        .contextMenu {
                            Button(
                                action: {
                                    edit(conversationStarter: conversationStarter)
                                },
                                label: {
                                    Label(title: {
                                        Text("Edit")
                                    }, icon: {
                                        Image(icon: .pencil)
                                    })
                                })
                            Button(
                                role: .destructive,
                                action: {
                                    delete(conversationStarter: conversationStarter)
                                },
                                label: { Label(title: { Text(.delete) }, icon: { Image(icon: .trash) })
                                })
                        }
                }
                addConversationStarterButton
            }.padding(.horizontal)
            .onAppear {
                self.conversationStarters = Array(settings.conversationStarters)
            }
            .animation(.default, value: self.conversationStarters)
            .sheet(item: $editingConversationStarter,
                   onDismiss: { self.editingConversationStarter = nil },
                   content: { editingConversationStarter in
                EditConversationStarterView(conversationStarter: editingConversationStarter)
            })
        }
    }
}

// MARK: - Functions
extension ConversationStarterRowView {
    
    private func addStandardConversationStarter(){
        // Create new conversation starter
        // Open edit modal for conversation starter
        settings.addNewStandardConversationStarter(completion: { newConversationStarter in
            
            // Open the editing dialogue.
            self.edit(conversationStarter: newConversationStarter)
            withAnimation {
                self.conversationStarters = Array(settings.conversationStarters)
            }

        })
    }
    
    private func addIntelligentConversationStarter(){
        // Create new conversation starter
        // Open edit modal for conversation starter
        settings.addNewIntelligentConversationStarter(completion: { newConversationStarter in
            
            // Open the editing dialogue.
            self.edit(conversationStarter: newConversationStarter)
            withAnimation {
                self.conversationStarters = Array(settings.conversationStarters)
            }
        })
        
    }
    
    func commitConversationStarterChanges() {
        settings.set(conversationStarters: self.conversationStarters)
    }
    
    private func delete(conversationStarter: ConversationStarterTemplate) {
        guard
            let index = settings.conversationStarters.firstIndex(of: conversationStarter),
            let localIndex = conversationStarters.firstIndex(of: conversationStarter)
        else {
            return
        }
        withAnimation {
            conversationStarters.remove(atOffsets: .init(integer: localIndex))
            settings.removeConversationStarters(atOffsets: .init(integer: index))
        }
    }
    
    private func edit(conversationStarter: ConversationStarterTemplate) {
        self.editingConversationStarter = conversationStarter
    }
}

extension ConversationStarterRowView {
    struct DragRelocateDelegate: DropDelegate {
        let item: ConversationStarterTemplate
        @Binding var localConvoStarters: [ConversationStarterTemplate]
        @Binding var currentlyDraggedItem: ConversationStarterTemplate?
        var commitChangesClosure: () -> Void
        
        func dropEntered(info: DropInfo) {
            guard item != currentlyDraggedItem,
                  let currentlyDraggedItem = currentlyDraggedItem,
                  let fromIndex = localConvoStarters.firstIndex(where: { $0.id == currentlyDraggedItem.id }),
                  let toIndex = localConvoStarters.firstIndex(where: { $0.id == item.id }),
                  fromIndex != toIndex
            else { return }
            
            withAnimation {
                localConvoStarters.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }

        func performDrop(info: DropInfo) -> Bool {
            currentlyDraggedItem = nil
            commitChangesClosure()
            return true
        }
    }
}

#if DEBUG
#Preview {
    ConversationStarterRowView(contact: .mocked)
}
#endif
