//
//  NativeContactView.swift
//  FollowUp
//
//  Created by Aaron Baw on 06/09/2024.
//

import SwiftUI
import Contacts
import ContactsUI

struct NativeContactView: UIViewControllerRepresentable {
    
    let contactID: String
    
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing SwiftUI view

    class Coordinator: NSObject {
        var parent: NativeContactView

        init(_ parent: NativeContactView) {
            self.parent = parent
        }

        // Selector method for dismiss button action
        @objc func dismissViewController() {
            parent.presentationMode.wrappedValue.dismiss() // Dismiss the SwiftUI view
        }
    }
    
    func makeCoordinator() -> Coordinator {
         return Coordinator(self)
     }

    func makeUIViewController(context: Context) -> UINavigationController {
        // Create a CNContactStore instance to fetch the contact
        let store = CNContactStore()

        // Use descriptorForRequiredKeys to fetch all required keys
        let keys = CNContactViewController.descriptorForRequiredKeys()

        do {
            // Fetch the contact by ID with the required keys
            let contact = try store.unifiedContact(withIdentifier: contactID, keysToFetch: [keys])

            // Create a CNContactViewController with the fetched contact
            let contactViewController = CNContactViewController(for: contact)
            contactViewController.allowsEditing = true // Set to true if you want to allow editing
            
            contactViewController.modalPresentationStyle = .automatic
            contactViewController.viewRespectsSystemMinimumLayoutMargins = true
            
            contactViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Close",
                style: .done,
                target: context.coordinator,
                action: #selector(context.coordinator.dismissViewController)
            )
            
            
            let navigationController = UINavigationController(rootViewController: contactViewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.navigationBar.prefersLargeTitles = true // If you want a large title appearance
            
            return navigationController
        } catch {
            print("Failed to fetch contact with ID \(contactID): \(error)")
            return UINavigationController()
        }
    }

    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No need to update the view controller here
    }
    
}

#if DEBUG
#Preview {
    NativeContactView(contactID: "1")
}
#endif
