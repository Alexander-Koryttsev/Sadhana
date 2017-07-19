//
//  DateUtilites.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/15/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

class DateUtility {

    static let shared = DateUtility()

    let weekDayShortFormatter = DateFormatter()
    let monthMediumFormatter = DateFormatter()

    init () {
        weekDayShortFormatter.dateFormat = "E"
        monthMediumFormatter.dateFormat = "LLLL YYYY"
    }
}

extension Date {
    var day : Int {
        get {
            return Calendar.current.component(.day, from: self)
        }
    }

    var weekDay : Int {
        get {
            return Calendar.current.component(.weekday, from: self)
        }
    }

    var weekDayShort : String {
        get {
            return DateUtility.shared.weekDayShortFormatter.string(from: self)
        }
    }

    var monthDate : Date {
        get {
            let calendar = Calendar.current

            let year = calendar.component(.year, from: self)
            let month = calendar.component(.month, from: self)

            let components = DateComponents(calendar: calendar, timeZone:TimeZone.create(), year: year, month: month)
            return components.date!
        }
    }

    var month: String {
        get {
            return DateUtility.shared.monthMediumFormatter.string(from: self).capitalized
        }
    }
}
