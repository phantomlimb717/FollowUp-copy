//
//  TimelineItem.swift
//  FollowUp
//
//  Created by Aaron Baw on 02/05/2025.
//

import Foundation
import RealmSwift

class TimelineItem: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var kind: Kind
    @Persisted var event: InteractionType
    @Persisted var time: Date = .now
    @Persisted var body: String?
    @Persisted var location: LocationSample?
    
    // MARK: - Computed Properties
    var title: String { self.event.title }
    var icon: Constant.Icon { self.event.icon }
    
    convenience init(kind: Kind, event: InteractionType, time: Date, body: String? = nil, location: LocationSample? = nil) {
        self.init()
        self.kind = kind
        self.event = event
        self.id = UUID().uuidString
        self.time = time
        self.body = body
        self.location = location
    }
    
    // MARK: - Static Convenience Initializers
    static func comment(body: String, time: Date = .now) -> TimelineItem {
        TimelineItem(kind: .bubble, event: .comment, time: time, body: body)
    }
    
    static func event(type interactionType: InteractionType, time: Date = .now, location: LocationSample? = nil) -> TimelineItem {
        TimelineItem(kind: .event, event: interactionType, time: time, body: nil, location: location)
    }
    
}

// MARK: - Enum Definitions
extension TimelineItem {
    // MARK: - Enums
    enum Kind: String, PersistableEnum {
        case bubble
        case event
    }

}

// MARK: - Identifiable Conformance
extension TimelineItem: Identifiable { }

// MARK: - Equatable Implementation
extension TimelineItem {
    static func == (lhs: TimelineItem, rhs: TimelineItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.kind == rhs.kind &&
        lhs.event == rhs.event &&
        lhs.time == rhs.time &&
        lhs.body == rhs.body
    }
}

// MARK: - Initialise from PendingInteraction
extension TimelineItem {
    convenience init(_ interaction: PendingInteraction) {
        self.init(kind: .event, event: interaction.type, time: interaction.date)
    }
}

#if DEBUG
extension TimelineItem {
    static var mockedBT: TimelineItem = .comment(body: "Spoke on the phone, seemed eager to come to Bible Talk.", time: .now.addingTimeInterval(-20003))
    
    static var mockedBirthday: TimelineItem = .comment(body: "Wished them a happy 26th Birthday. They were encouraged, but upset because they stubbed their toe. Need to check in next week to be sure they are okay.")

    static var mockedCall: TimelineItem = .event(type: .call, time: .now.addingTimeInterval(-30000))
    static var mockedFollowUp: TimelineItem = .event(type: .followUp, time: .now.addingTimeInterval(-200300))
    static var mockedFirstMet: TimelineItem = {
        let date: Date = .now.addingTimeInterval(-203000)
        let location: LocationSample = .init(arrivalDate: date, latitude: 53.1234112, longitude: 0.1342334, horizontalAccuracy: 100)
        return .event(type: .firstMet, time: .now, location: location)
    }()
    
    static var mockedMessage: TimelineItem = .event(type: .sms, time: .now.addingTimeInterval(-900000))

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
