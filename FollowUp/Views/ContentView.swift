//
//  ContentView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Contacts
import SwiftUI
import Toasts

struct ContentView: View {

    @State var selectedTab: Int = 0
    @State var contactSheet: ContactSheet?
    @State var settingsSheetShown: Bool = false
    @State private var rotation: Double = 0
    @State private var contactInteractorState: ContactInteractorState = .fetchingContacts
    @AppStorage("v2firstLaunch") var firstLaunch: Bool = true
    @AppStorage("v.7FirstLaunch") var newVersionLaunch: Bool = true
    @EnvironmentObject var followUpManager: FollowUpManager
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.presentToast) private var presentToast
    

    var body: some View {
            TabView(selection: $selectedTab, content:  {
                
                // New Contacts View
                NavigationView {
                    NewContactsView(
                        store: followUpManager.store,
                        contactsInteractor: followUpManager.contactsInteractor
                    )
                    .navigationBarTitle("Contacts")
                    .toolbar(content: {
                        ZStack {
                            Button(action: {
                                self.settingsSheetShown = true
                            }, label: {
                                Image(icon: .settings)
                            })
                            
                            if contactInteractorState == .fetchingContacts {
                                CircularLoadingSpinner(
                                    lineWidth: 4,
                                    colour: .accent,
                                    showBackgroundCircle: true
                                )
                                .frame(width: 19, height: 19)
                                .offset(x: -25, y: 0) // This positions it exactly at the same place as the cog
                                .transition(.opacity)
                            }
                        }
                        
                    })
                }
                .animation(.easeInOut, value: contactInteractorState)
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
                .tag(1)
                
                    
                // FollowUps View
                NavigationView {
                    FollowUpsView(store: followUpManager.store, contactsInteractor: followUpManager.contactsInteractor)
                        .navigationBarTitle("FollowUps")
                }
                .tabItem {
                    Label("FollowUp", systemImage: "arrow.up.message.fill")
                }
                .background(Color(.systemGroupedBackground))
                .tag(2)
            })
            .sheet(isPresented: $settingsSheetShown, content: {
                SettingsSheetView()
            })
            .sheet(item: $contactSheet, onDismiss: {
                followUpManager.contactsInteractor.hideContactSheet()
            }, content: {
                ContactSheetView(
                    kind: .modal,
                    sheet: $0,
                    onClose: {
                        followUpManager.contactsInteractor.hideContactSheet()
                    })
            })
            .sheet(isPresented: $firstLaunch, onDismiss: {
                self.firstLaunch = false
            }, content: {
                OnboardingView()
            })
            .onReceive(followUpManager.contactsInteractor.contactSheetPublisher, perform: { contactSheet in
                self.contactSheet = contactSheet
            })
            .onReceive(followUpManager.contactsInteractor.statePublisher, perform: { contactInteractorState in
                self.contactInteractorState = contactInteractorState
            })
            .onChange(of: selectedTab, perform: { Log.info("Tab changed to \($0)") })
            .onChange(of: scenePhase, perform: { phase in
                switch phase {
                case .active:
                    self.handlePendingInteractions()
                    self.followUpManager.contactsInteractor.fetchContacts()
                default: break
                }
            })
            .onAppear {
                if (!firstLaunch) { self.followUpManager.configureNotifications() }
            }
    }
    
    // MARK: - Functions
    func handlePendingInteractions(onComplete: (() -> Void)? = nil) {
        guard let lastInteraction = followUpManager.interactionManager.lastInteraction else { onComplete?()
            return
        }
        
        let toastDuration: TimeInterval = 5.0
        var confirmInteraction: Bool = true
        
        let eventTitle = lastInteraction.type.title
        let toastValue: ToastValue = .init(
            message: "Detected \(eventTitle) with \(lastInteraction.contactName)",
            button: .init(
                title: "Cancel",
                color: .red,
                action: {
                   confirmInteraction = false
                }
            ),
            duration: toastDuration
        )
        
        presentToast(toastValue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration, execute: {
            if confirmInteraction {
                self.followUpManager.interactionManager.confirm(lastInteraction, onComplete: { self.handlePendingInteractions(onComplete: onComplete)
                })
            } else {
                self.followUpManager.interactionManager.dismiss(lastInteraction)
            }
        })
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FollowUpManager())
    }
}
