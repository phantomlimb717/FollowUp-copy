//
//  ContactTimeline.swift
//  FollowUp
//
//  Created by Aaron Baw on 02/05/2025.
//

import Foundation
import RealmSwift

enum TimelineItemKind {
    case bubble
    case event
}

protocol TimelineItem: Object, ObjectKeyIdentifiable {
    var kind: TimelineItemKind { get }
    var id: String { get }
    var icon: Constant.Icon { get }
    var title: String { get }
    var time: Date { get }
}

class BubbleTimelineItem: Object, TimelineItem {
    let kind: TimelineItemKind = .bubble
    var id: String = UUID().uuidString
    var icon: Constant.Icon = .chatBubbles
    var title: String
    var time: Date = .now
    var body: String
    
    init(title: String, time: Date = .now, body: String) {
        self.title = title
        self.time = time
        self.body = body
    }
}

class EventTimelineItem: Object, TimelineItem {
    let kind: TimelineItemKind = .event
    var id: String = UUID().uuidString
    var icon: Constant.Icon
    var title: String
    var time: Date  = .now
    
    init(event: EventType, title: String, time: Date) {
        self.icon = event.icon
        self.title = title
        self.time = time
    }
    
    enum EventType {
        case call
        case message
        case whatsApp
        case followUp
        var icon: Constant.Icon {
            switch self {
            case .call: return .phone
            case .message: return .chatBubbles
            case .whatsApp: return .whatsApp
            case .followUp: return .arrowForwardUp
            }
        }
    }
}

#if DEBUG
extension BubbleTimelineItem {
    static var mockedBT: BubbleTimelineItem = .init(title: "Comment", time: .now.addingTimeInterval(-20003), body: "Spoke on the phone, seemed eager to come to Bible Talk.")
    static var mockedBirthday: BubbleTimelineItem = .init(title: "Comment", body: "Wished them a happy 26th Birthday. They were encouraged, but upset because they stubbed their toe. Need to check in next week to be sure they are okay.")
}

extension EventTimelineItem {
    static var mockedCall: EventTimelineItem = .init(event: .call, title: "Phone Call", time: .now.addingTimeInterval(-30000))
    static var mockedFollowUp: EventTimelineItem = .init(event: .followUp, title: "Followed Up", time: .now.addingTimeInterval(-200300))
    static var mockedMessage: EventTimelineItem = .init(event: .message, title: "iMessage/SMS", time: .now.addingTimeInterval(-900000))
}

extension TimelineItem {
    static var mockedItems: [any TimelineItem] {
        [
            BubbleTimelineItem.mockedBT,
            EventTimelineItem.mockedCall,
            BubbleTimelineItem.mockedBirthday,
            EventTimelineItem.mockedFollowUp
        ]
    }
}

#endif
