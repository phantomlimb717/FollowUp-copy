//
//  Localisation.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import Foundation
import SwiftUI

extension LocalizedStringKey {
    
    // MARK: - FollowUps View
    static let noHighlightsHeader: LocalizedStringKey = "No Highlights"
    static let noHighlightsSubheader: LocalizedStringKey = "Tap the 'Highlight' button on a Contact sheet to add them to this list."

    // MARK: - New Contacts View
    static let fetchingContactsHeader: LocalizedStringKey = "Fetching Contacts"

    static let awaitingAuthorisationHeader: LocalizedStringKey = "Awaiting Authorisation"
    static let awaitingAuthorisationSubheader: LocalizedStringKey = "Please allow FollowUp to read from your Contacts"

    static let authorisationDeniedHeader: LocalizedStringKey = "Contacts Denied"
    static let authorisationDeniedSubheader: LocalizedStringKey = "FollowUp needs permission to read from your device's contacts to work properly. Please enable this in Settings."

    // MARK: - Edit Conversastion Starter View
    static let editConversationStarterName: LocalizedStringKey = "Name"
    static let editConversationStarterChooseNameDescription: LocalizedStringKey = "Optional. Choose a short name for this conversation starter."
    
    static let editConversationStarterTitle: LocalizedStringKey = "Edit Conversation Starter"
    static let editConversationStarterKindPickerTitle: LocalizedStringKey = "Conversation Starter Kind"

    static let editConversationStarterMessageTitle: LocalizedStringKey = "Message"
    static let editConversationStarterMessageDescription: LocalizedStringKey = "When writing your message template, use the <NAME> keyword and this will be replaced for the contact's first name when you use the conversation starter."

    static let editConversationStarterAISegmentDescription: LocalizedStringKey = "AI-enabled conversation starters use AI to automatically generate a personalised, unique conversation starter for your contact. ✨"

    static let editConversationStarterPromptTitle: LocalizedStringKey = "Prompt"
    static let editConversationStarterPromptDescription: LocalizedStringKey = "Choose a prompt to instruct the AI on how to compose your message."

    static let editConversationStarterContextTitle: LocalizedStringKey = "Context"
    static let editConversationStarterContextDescription: LocalizedStringKey = "Optional. Add some extra context to help the AI construct a tailor-made message. "

    static let editConversationStarterSaveButtonTitle: LocalizedStringKey = "Save"

    // MARK: - Welcome Screen
    static let welcomeScreenTitle: LocalizedStringKey = "Welcome to FollowUp"
    static let welcomeScreenContinueButtonTitle: LocalizedStringKey = "Continue"

    // MARK: - Settings
    static let followUpReminderToggleText: LocalizedStringKey = "FollowUp Reminders"
    static let followUpReminderFooterText: LocalizedStringKey = "Sends you periodic reminders to follow up and hit your goal."

    // MARK: - Edit Tag
    static let delete: LocalizedStringKey = "Delete"
    static let newTag: LocalizedStringKey = "New Tag"
    
    // MARK: - Welcome View
    static let organiseFeatureTitle: LocalizedStringKey = "Organise"
    static let organiseFeatureDescription: LocalizedStringKey = "See who you met this week and add them to a dedicated list."
    
    static let setGoalsFeatureTitle: LocalizedStringKey = "Set Goals"
    static let setGoalsFeatureDescription: LocalizedStringKey = "Set daily goals and track your progress."
    
    static let autoComposeFeatureTitle: LocalizedStringKey = "Auto-Compose"
    static let autoComposeFeatureDescription: LocalizedStringKey = "Use conversation starters to quickly compose messages."
    
    static let discoverMoreFeaturesHint: LocalizedStringKey = "Discover more on these features by tapping settings."
    
}
