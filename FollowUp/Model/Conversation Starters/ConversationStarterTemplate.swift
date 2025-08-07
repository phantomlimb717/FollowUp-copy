//
//  ConversationStarterTemplate.swift
//  FollowUp
//
//  Created by Aaron Baw on 26/01/2023.
//

import Foundation
import RealmSwift

// MARK: -
enum ConversationStarterKind: Codable, Hashable, Equatable, CaseIterable {
    case standard
    case intelligent
    
    var buttonTitle: String {
        switch self {
        case .standard: return "Standard"
        case .intelligent: return "Intelligent"
        }
    }
    
    var icon: Constant.Icon {
        switch self {
        case .intelligent: return .chatWithWaveform
        case .standard: return .chatBubbles
        }
    }
}

// MARK: -
struct ConversationStarterTemplate: Codable, Hashable, Identifiable, CustomPersistable {
    
    // TODO: Need to completely fill this out.
    static func == (lhs: ConversationStarterTemplate, rhs: ConversationStarterTemplate) -> Bool {
        return  lhs.starter.equals(rhs.starter) &&
        lhs.title == rhs.title &&
        lhs.kind == rhs.kind &&
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        lhs.platform == rhs.platform
    }
    
    typealias PersistedType = Data
    
    enum Platform: Codable, Hashable, Equatable {
        case whatsApp

        var icon: Constant.Icon {
            switch self {
            case .whatsApp: return .whatsApp
            }
        }
    }
        
    var label: String?
    var starter: any ConversationStarting
    var platform: Platform
    var id: String

    var kind: ConversationStarterKind {
        didSet {
            guard self.kind != self.starter.kind else { return }
            switch self.kind {
            case .standard:
                self.starter = StandardConversationStarter(template: "")
            case .intelligent:
                self.starter = IntelligentConversationStarter(prompt: "")
            }
        }
    }
    
    var persistableValue: Data {
        (try? JSONEncoder().encode(self)) ?? .init()
    }
    
    // MARK: - Computed Properties
    var title: String {
        guard let label = label, !label.isEmpty else {
            return self.starter.title
        }
        return label
    }
    
    // MARK: - Initialisers
    init(persistedValue: Data) {
        let decodedObject = try? JSONDecoder().decode(Self.self, from: persistedValue)
        self = decodedObject ?? .init(template: "", platform: .whatsApp)
    }
    
    /// Create a standard conversation starter.
    init(
        label: String? = nil,
        template: String,
        platform: Platform,
        id: String? = nil
    ) {
        self.kind = .standard
        self.starter = StandardConversationStarter(template: template)
        self.label = label
        self.platform = platform
        self.id = id ?? UUID().uuidString
    }
    
    /// Create an intelligent conversation starter
    init(
        label: String? = nil,
        prompt: String,
        context: String?,
        platform: Platform,
        id: String = UUID().uuidString
    ) {
        self.kind = .intelligent
        self.starter = IntelligentConversationStarter(prompt: prompt, context: context)
        self.label = label
        self.platform = platform
        self.id = id 
    }
    
    // MARK: - Methods
    
    /// Uses the current template to create a conversation starter button action given the platform and contact.
    func buttonAction(
        contact: any Contactable,
        interactionManager: InteractionManager
    ) throws -> ButtonAction? {
        switch self.platform {
        case .whatsApp:
            guard let number = contact.phoneNumber else { return nil }
            return .whatsApp(number: number, generateText: { completion in
                let contactCopy = contact.concrete
                self.starter.generateFormattedText(withContact: contactCopy) { result in
                    DispatchQueue.main.async {
                        interactionManager.beginInteraction(type: .whatsApp, with: contact)
                        completion(result)
                    }
                }
            })
        }
    }
    
    enum CodingKeys: CodingKey {
        case label
        case kind
        case starter
        case platform
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.label, forKey: .label)
        try container.encode(self.platform, forKey: .platform)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.kind, forKey: .kind)
        try container.encode(self.starter, forKey: .starter)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.platform = try container.decode(Platform.self, forKey: .platform)
        self.id = try container.decode(String.self, forKey: .id)

        // We first determine the "Kind" of Conversation Starter so that we know how to decode the object, since the 'self.starter' property is a protocol. This allows us to know which concrete structure to decode.
        let kind = try container.decode(ConversationStarterKind.self, forKey: .kind)
        self.kind = kind
        
        switch kind {
        case .standard: self.starter = try container.decode(StandardConversationStarter.self, forKey: .starter)
        case .intelligent: self.starter = try container.decode(IntelligentConversationStarter.self, forKey: .starter)
        }
    }
}

extension ConversationStarterTemplate {
    enum StarterGenerationError: Error {
        case couldNotGenerate(Error)
    }
}

// MARK: - Default Values
extension ConversationStarterTemplate {
    static var arrangeForCoffee: ConversationStarterTemplate {
        .init(label: "Arrange for coffee", template: "Hey \(Constant.ConversationStarter.Token.name)! How are you? I was wondering if you'd be free for a coffee this week?", platform: .whatsApp)
    }
    
    static var howAreYou: ConversationStarterTemplate {
        .init(label: "How are you?", template: "Hey \(Constant.ConversationStarter.Token.name)! How are you?", platform: .whatsApp)
    }
    
    static var iceBreaker: ConversationStarterTemplate {
        .init(
            label: "Ice Breaker",
            prompt: "Write a WhatsApp message to follow up with the person using what you know about them. The message needs to be creative, relatable and personal to the person. It should be a conversation starter that can lead into more conversation. E.g “Hey man, it was great meeting you at X, how are the studies going?”. Make it short and informal.",
            context: nil, platform: .whatsApp)
    }
    
    static var standardExamples: [ConversationStarterTemplate] = [
        .arrangeForCoffee,
        .howAreYou
    ]
    
    static var intelligentExamples: [ConversationStarterTemplate] = [
        .iceBreaker
    ]
}
