//
//  Date+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/12/2022.
//

import Foundation

extension Date {
    func setting(_ component: Calendar.Component, to value: Int) -> Date? {
        Calendar.current.date(bySetting: component, value: value, of: self)
    }
    
    func adding(_ value: Int, to component: Calendar.Component) -> Date? {
        Calendar.current.date(byAdding: component, value: value, to: self)
    }
    
    var formattedRelativeTimeSinceNow: String {
        Constant.relativeDateTimeFormatter
            .localizedString(
                for: self,
                   relativeTo: .now
            )
    }
    
    var formattedAbsoluteDate: String {
        self.formatted(.dateTime.day().month(.wide).year().hour().minute())
    }
}
