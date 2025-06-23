//
//  ContactTimeline.swift
//  FollowUp
//
//  Created by Aaron Baw on 02/05/2025.
//

import Foundation
import RealmSwift



//protocol TimelineItemRepresentable: Object, ObjectKeyIdentifiable {
//    var kind: TimelineItemKind { get }
//    var id: String { get }
//    var icon: Constant.Icon { get }
//    var title: String { get }
//    var time: Date { get }
//}

class TimelineItem: Object {
    
    
    // MARK: - Enums
    enum Kind: String, PersistableEnum {
        case bubble
        case event
    }
    
    enum EventType: String, PersistableEnum {
        case call
        case message
        case comment
        case whatsApp
        case followUp
        var icon: Constant.Icon {
            switch self {
            case .call: return .phone
            case .message: return .chatBubbles
            case .comment: return .bubble
            case .whatsApp: return .whatsApp
            case .followUp: return .arrowForwardUp
            }
        }
        
        var title: String {
            switch self {
            case .call: return "Call"
            case .comment: return "Comment"
            case .followUp: return "FollowUp"
            case .message: return "Message"
            case .whatsApp: return "WhatsApp"
            }
        }
        
    }
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var kind: Kind
    @Persisted var event: EventType
    @Persisted var time: Date = .now
    @Persisted var body: String?
    
    // MARK: - Computed Properties
    var title: String { self.event.title }
    var icon: Constant.Icon { self.event.icon }
    
    convenience init(kind: Kind, event: EventType, time: Date, body: String? = nil) {
        self.init()
        self.kind = kind
        self.event = event
        self.id = UUID().uuidString
        self.time = time
        self.body = body
    }
    
    // MARK: - Static Convenience Initializers
    static func comment(body: String, time: Date = .now) -> TimelineItem {
        TimelineItem(kind: .bubble, event: .comment, time: time, body: body)
    }
    
    static func event(type eventType: EventType, time: Date = .now) -> TimelineItem {
        TimelineItem(kind: .event, event: eventType, time: time)
    }
    
}

// MARK: - Equatable Conformance
extension TimelineItem: Identifiable { }

#if DEBUG
extension TimelineItem {
    static var mockedBT: TimelineItem = .comment(body: "Spoke on the phone, seemed eager to come to Bible Talk.", time: .now.addingTimeInterval(-20003))
    
    static var mockedBirthday: TimelineItem = .comment(body: "Wished them a happy 26th Birthday. They were encouraged, but upset because they stubbed their toe. Need to check in next week to be sure they are okay.")

    static var mockedCall: TimelineItem = .event(type: .call, time: .now.addingTimeInterval(-30000))
    static var mockedFollowUp: TimelineItem = .event(type: .followUp, time: .now.addingTimeInterval(-200300))
    
    static var mockedMessage: TimelineItem = .event(type: .message, time: .now.addingTimeInterval(-900000))

    static var mockedItems: [TimelineItem] {
        [
            TimelineItem.mockedBT,
            TimelineItem.mockedCall,
            TimelineItem.mockedBirthday,
            TimelineItem.mockedFollowUp
        ]
    }
}

#endif
