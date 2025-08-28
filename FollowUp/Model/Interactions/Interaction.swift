//
//  Interaction.swift
//  FollowUp
//
//  Created by Aaron Baw on 25/06/2025.
//

import Foundation
import RealmSwift
import Toasts

protocol Interactable { }

enum InteractionType: String, PersistableEnum {
    case call
    case sms
    case comment
    case whatsApp
    case followUp
    case firstMet

    var icon: Constant.Icon {
        switch self {
        case .call: return .phone
        case .sms: return .chatBubbles
        case .comment: return .bubble
        case .whatsApp: return .whatsApp
        case .followUp: return .arrowForwardUp
        case .firstMet: return .mapPin
        }
    }
    
    var title: String {
        switch self {
        case .call: return "Call"
        case .comment: return "Comment"
        case .followUp: return "FollowUp"
        case .sms: return "Message"
        case .whatsApp: return "WhatsApp"
        case .firstMet: return "First Met"
        }
    }
    
}

// Not to be confused with `TimelineItem`s, this is purely to handle pending interactions that may or may not be confirmed by the user. These can then get converted into TimelineItems.
struct PendingInteraction: Interactable, Identifiable, Equatable {
    let id = UUID()
    let type: InteractionType
    let contactId: String
    let contactName: String
    var date: Date = .now
}
