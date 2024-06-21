//
//  FollowUpFrequency.swift
//  FollowUp
//
//  Created by Aaron Baw on 31/08/2023.
//

import Foundation
import RealmSwift

/// Indicates how often a contact should be followed up with. FollowUp will use this to intelligently sort contacts in the follow up list and remind users when it's time to follow up with certain users.
enum FollowUpFrequency: String, PersistableEnum {
    case daily
//    case semidaily
    case weekly
//    case biweekly
    case monthly
    case quarterly
    case yearly
    
    var readableDescription: String {
        switch self {
        case .daily: return "Every day"
//        case .semidaily: return "Every few days"
        case .weekly: return "Every week"
//        case .biweekly: return "Every other week"
        case .monthly: return "Every month"
        case .quarterly: return "Every few months"
        case .yearly: return "Every year"
        }
    }
    
    func nextDateComponents(forDate date: Date) -> DateComponents {
        switch self {
        case .daily: return Components.dailyComponent
        case .weekly: return Components.weeklyComponent
        case .monthly: return Components.monthlyComponent(forDate: date)
        case .quarterly: return Components.quarterlyComponent(forDate: date)
        case .yearly: return Components.yearlyComponent
        }
    }
    
    func nextFollowUpDate(forDate date: Date) -> Date? {
        let nextDateComponents = nextDateComponents(forDate: date)
        return Calendar.current.nextDate(
            after: date,
            matching: nextDateComponents,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
    }
}


extension FollowUpFrequency {
    
    enum Components {
        
        static let dailyComponent: DateComponents = {
            let locale = Locale(identifier: "en_US")
            var calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(hour: 12)
            return components
        }()
        
        // By default, we use '2', i.e. 'Monday' as the weeklyFollowUpDay. In most Gregorian calendars, this is the second day of the week, for the other half of the world, it is actually the first day of the week.
        // TODO: - Ensure that this is consistent across Locales.
        static let weeklyComponent: DateComponents = {
            var components = Self.dailyComponent
            components.weekday = 2
            return components
        }()
        
        // Semi-Daily up days will be Monday, Wednesday and Saturday. Days 2, 4 and 6.
        //    static func semiDailyFollowUpDay(forDate date: Date) -> DateComponents {
        //        var components = Self.dailyFollowUpHour
        //        let day = Calendar.current.component(.weekday, from: date)
        //
        //        components.
        //    }
        
        static func monthlyComponent(forDate date: Date) -> DateComponents {
            let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: date, wrappingComponents: true)
            let nextMonthComponent = Calendar.current.component(.month, from: nextMonthDate ?? date)
            var components = Self.weeklyComponent
            components.month = nextMonthComponent
            return components
        }
        
        static func quarterlyComponent(forDate date: Date) -> DateComponents {
            let month = Calendar.current.component(.month, from: date)
            let currentQuarter = (month + 2) / 3
            let nextQuarter = (currentQuarter % 4) + 1
            var components = Self.monthlyComponent(forDate: date)
            components.month = (nextQuarter - 1) * 3 + 1
            return components
        }
        
        static let yearlyComponent: DateComponents = {
            var components = Self.weeklyComponent
            components.month = 12
            return components
        }()

    }

}
