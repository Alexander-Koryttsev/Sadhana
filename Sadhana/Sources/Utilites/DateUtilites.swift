//
//  DateUtilites.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/15/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

class DateUtilities {
    static func monthFrom(date:Date) -> Date {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        let components = DateComponents(calendar: calendar, timeZone:TimeZone.create(), year: year, month: month)
        return components.date!
    }
}
