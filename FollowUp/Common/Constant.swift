//
//  Constant.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Foundation
import CoreGraphics
import SwiftUI
import RealmSwift

enum Constant {
    
    // MARK: - App Identifier
    static let appIdentifier: String = "com.bazel.followup"

    // MARK: - Padding
    static let verticalPadding: CGFloat = 10.0

    // MARK: - Misc
    static let cornerRadius: CGFloat = 15.0
    static let buttonCornerRadius: CGFloat = 8.0
    static let borderedButtonPadding: CGFloat = 15.0

    // MARK: - Date Formatting
    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = .init()

    // MARK: - Round Badge
    enum ContactBadge {
        
        enum Size {
            case small
            case large
            
            var width: CGFloat {
                switch self {
                case .small: return 23
                case .large: return 50
                }
            }
            
            var padding: CGFloat {
                switch self {
                case .small: return 10.0
                case .large: return 20.0
                }
            }
        }

    }

    // MARK: - Icons
    enum Icon: String, PersistableEnum {
        case arrowCirclePath = "arrow.trianglehead.2.clockwise.rotate.90"
        case arrowForwardUp = "arrow.up.forward"
        case arrowUpChatBubble = "arrow.up.message.fill"
        case bolt = "bolt.fill"
        case bubble = "bubble.fill"
        case chatBubbles = "bubble.left.and.bubble.right.fill"
        case chatWithElipses = "ellipsis.message.fill"
        case chatWithWaveform = "message.and.waveform.fill"
        case checkmark = "checkmark"
        case chevronRight = "chevron.right"
        case clock = "clock.arrow.circlepath"
        case close = "xmark.circle.fill"
        case closeOutline = "xmark"
        case circle = "circle"
        case email = "envelope.fill"
        case locationArrow = "location.fill"
        case lock = "lock.fill"
        case lockWithExclamationMark = "lock.trianglebadge.exclamationmark"
        case mapPin = "mappin.and.ellipse"
        case minus = "minus"
        case notification = "bell.badge"
        case partyPopper = "party.popper.fill"
        case pencil = "pencil"
        case pencilWithSquare = "square.and.pencil"
        case pencilWithBubble = "bubble.and.pencil"
        case personWithAtSymbol = "person.crop.square.filled.and.at.rectangle.fill"
        case personWithCheckmark = "person.crop.circle.fill.badge.checkmark"
        case personWithClock = "person.badge.clock.fill"
        case personWithDescription = "person.text.rectangle.fill"
        case phone = "phone.fill"
        case plus = "plus"
        case settings = "gearshape.fill"
        case sms = "bubble.left.fill"
        case star = "star.fill"
        case starWithText = "text.badge.star"
        case slashedStar = "star.slash.fill"
        case tag = "tag.fill"
        case target = "target"
        case thumbsUp = "hand.thumbsup.fill"
        case trash = "trash.fill"
        case whatsApp = "whatsAppIcon"
        
        static let mediumSize: CGFloat = 30.0

        enum Kind {
            case asset
            case sfSymbol
        }

        var kind: Kind {
            switch self {
            case .arrowCirclePath, .arrowForwardUp, .arrowUpChatBubble, .bolt, .bubble, .chatBubbles, .chatWithElipses, .chatWithWaveform, .checkmark, .chevronRight, .clock, .closeOutline, .close, .circle, .email, .locationArrow, .lock, .lockWithExclamationMark, .mapPin, .minus, .notification, .partyPopper, .pencil, .pencilWithSquare, .pencilWithBubble, .personWithAtSymbol, .personWithCheckmark, .personWithClock, .personWithDescription, .phone, .plus, .settings, .sms, .star, .starWithText, .slashedStar, .tag, .target, .thumbsUp, .trash: return .sfSymbol
            case .whatsApp: return .asset
            }
        }
    }
    
    // MARK: - Graphic
    enum Graphic: String {
        case onboardingAddPeopleEffortlessly
        case onboardingContactTimeline
        case onboardingFollowupRows
        case onboardingNeverLoseTouch
        case onboardingNotificationGraphic
        case onboardingStartBetterConversationsGraphic
    }

    // MARK: - Contact Card
    enum ContactCard {
        static let minSize: CGFloat = 200.0
    }

    // MARK: - Contact Sheet
    enum ContactSheet {
        static let verticalSpacing: CGFloat = 10.0
        static let maxHeight: CGFloat = 400.0
        static let noHighlightsViewMaxContentWidth: CGFloat = 250.0
        static let noteViewMaxHeight: CGFloat = 150.0
        static let bottomPaddingForFollowUpDetails: CGFloat = 120.0
    }
    
    // MARK: - Hero Message
    enum HeroMessage {
        static let verticalSpacing: CGFloat = 10.0
        static let maxContentWidth: CGFloat = 250.0
    }

    // MARK: - Conversation Action Button
    enum ConversationActionButton {
        static let maxWidth: CGFloat = 200.0
    }
    
    // MARK: - Circular Loading Spiner
    enum CircularLoadingSpinner {
        static let defaultSize: CGFloat = 25.0
        static let defaultLineWidth: CGFloat = 5.0
        static let defaultBackgroundCircleOpacity: CGFloat = 0.50
        static let defaultColour: Color = .blue
    }
    
    // MARK: - Tags
    enum Tag {
        
        enum Small {
            static let padding: CGFloat = 4.0
            static let cornerRadius: CGFloat = 5.0
            static let maxWidth: CGFloat = 50.0
        }
        
        enum Normal {
            static let padding: CGFloat = 7.0
            static let cornerRadius: CGFloat = 5.0
            static let maxWidth: CGFloat = 70.0
        }
    }

    // MARK: - Keys
    enum Key {
        static let followUpStore: String = "storage.FollowUpStore"

        enum FollowUpStore {
            static let contacts: String = "storage.FollowUpStore.contacts"
            static let contactDictionary: String = "storage.FollowUpStore.contactDictionary"
        }
    }
    
    // MARK: - Contact List
    enum ContactList {
        static let maxContactsForNonLazyVStack: Int = 20
        static let verticalSpacing: CGFloat = 20.0
        static let newContactsBadgeSize: CGFloat = 22.0
    }
    
    // MARK: - Search
    enum Search {
        static let contactSearchDebounce: RunLoop.SchedulerTimeType.Stride = 0.5
        static let tagSearchDebounce: RunLoop.SchedulerTimeType.Stride = 0.1
        static let maxNumberOfDisplayedSearchTagSuggestions: Int = 9
        static let suggestedTagViewTopPadding: CGFloat = 7.0
    }
    
    
    // MARK: - Secrets
    enum Secrets {
        static let openAIUserDefaultsKey: String = "openAIKey"
        static let OPENAI_API_KEY: String? = Bundle.main.object(forInfoDictionaryKey: "OPEN_API_KEY") as? String
    }
    
    // MARK: - Conversation Starter
    enum ConversationStarter {
        
        enum Token: String, CaseIterable {
            case name = "<NAME>"
            
            var title: String {
                switch self {
                case .name: return "Name"
                }
            }
        }
        
        static let defaultMaxTokenGenerationLength: Int = 1000
    }
    
    // MARK: - Notifications
    enum Notification {
        static let defaultNotificationTriggerHour: Int = 9
        static let defaultNotificationTriggerMinute: Int = 0
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static let defaultPages: [OnboardingPage] = [
            .init(
                graphic: .onboardingNeverLoseTouch,
                title: "Never lose touch again",
                description: "FollowUp helps you stay connected to the people that matter."),
            .init(
                graphic: .onboardingAddPeopleEffortlessly,
                title: "Add people, effortlessly",
                description: "Add new contacts to your phone, they’ll show up here too, automatically.",
                onAppear: [.requestContactsPermission(delay: 0)]
            ),
            .init(
                graphic: .onboardingStartBetterConversationsGraphic,
                title: "Start better conversations",
                description: "Use AI-generated messages – tailored for each contact and moment."
            ),
            .init(
                graphic: .onboardingNotificationGraphic,
                title: "Get a nudge",
                description: "FollowUp sends you a gentle reminder to reconnect with people you’ve met.",
                onAppear: [.requestNotificationPermission(delay: 0.5)]
            ),
            .init(
                graphic: .onboardingContactTimeline,
                title: "Remember every interaction",
                description: "FollowUp helps you keep track of your every interaction – calls, text, and more."
            )
        ]
    }
    
    // MARK: - Processing
    enum Processing {
        /// Determines the total number of contacts that will be processed within a background task. Used to prevent background tasks from failing when users have very large contact lists.
        static let numberOfContactsToProcessInBackground = 100
        static let followUpRemindersTaskIdentifier = "\(Constant.appIdentifier).followupreminders"
    }
    
    // MARK: - Frequency Defaults
    /// Frequency defaults are used to calculate the 'outOfTouch' delta (i.e., how long it has been since a contact should have been contacted). If a contact is to be followed up with 'every day', the _time_ of that day should be consistent across all contacts (e.g. 12:00pm). If a user determines a contact should be followed up with every day, then the first reminder will come the next day at 12:00pm (or the hour that has been set in 'dailyFollowUpHour').
    enum FollowUpFrequency {
        
        static let dailyFollowUpHour: DateComponents = {
            let locale = Locale(identifier: "en_US")
            var calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(hour: 12)
            return components
        }()
        
        // By default, we use '2', i.e. 'Monday' as the weeklyFollowUpDay. In most Gregorian calendars, this is the second day of the week, for the other half of the world, it is actually the first day of the week.
        // TODO: - Ensure that this is consistent across Locales.
        static let weeklyFollowUpDay: DateComponents = {
            var components = Self.dailyFollowUpHour
            components.weekday = 2
            return components
        }()
        
        static let monthlyFollowUpDay: DateComponents = {
            var components = Self.weeklyFollowUpDay
            components.weekOfMonth = 1
            return components
        }()
        
    }
    
    // MARK: - Contact Timeline
    enum ContactTimeline {
        static let cornerRadius: CGFloat = 15
        static let borderWidth: CGFloat = 1.5
        static let commentBoxHorizontalPadding: CGFloat = 12.0
        static let commentBoxVerticalPadding: CGFloat = 10.0
    }
    
    // MARK: - Vertical Divider
    enum VerticalDivider {
        static let defaultWidth: CGFloat = 2.0
        static let defaultHeight: CGFloat = 10.0
    }
    
    // MARK: - Location
    enum Location {
        static let linkingThresholdSeconds: TimeInterval = 60 * 60
    }
}
