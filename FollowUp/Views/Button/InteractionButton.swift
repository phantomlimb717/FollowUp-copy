//
//  InteractionButton.swift
//  FollowUp
//
//  Created by Aaron Baw on 25/06/2025.
//

import SwiftUI

/// Executes an action and starts a pending interaction
struct InteractionButton: View {
    
    // MARK: - Stored Properties
    @EnvironmentObject private var interactionManager: InteractionManager
    var action: ButtonAction
    var contact: any Contactable
    
    var icon: Constant.Icon {
        switch action {
        case .sms:
            return .sms
        case .call:
            return .phone
        case .whatsApp:
            return .whatsApp
        case .other:
            return .circle
        }
    }
    
    var interactionType: InteractionType? {
        switch action {
        case .sms:
            return .sms
        case .call:
            return .call
        case .whatsApp:
            return .whatsApp
        case .other:
            return nil
        }
    }
    
    
    var body: some View {
        CircularButton(icon: self.icon, action: {
            if let interactionType = self.interactionType {
                self.interactionManager.beginInteraction(type: interactionType, with: contact)
            }
            return action
        })
    }
}

#if DEBUG
#Preview {
    InteractionButton(action: .call(number: .mocked), contact: .mocked)
}
#endif
