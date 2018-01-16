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
    let dateShortFormatter = DateFormatter()

    init () {
        weekDayShortFormatter.dateFormat = "E"
        monthMediumFormatter.dateFormat = "LLLL YYYY"
        dateShortFormatter.dateStyle = .medium
    }
}

extension Date {

    //MARK: Component
    var minute : Int {
        get {
            return Calendar.local.component(.minute, from: self)
        }
    }

    var hour : Int {
        get {
            return Calendar.local.component(.hour, from: self)
        }
    }

    var day : Int {
        get {
            return Calendar.local.component(.day, from: self)
        }
    }

    var weekDay : Int {
        get {
            return Calendar.local.component(.weekday, from: self)
        }
    }

    var weekDayIndex : Int {
        get {
            return Calendar.local.orderedWeekDays.index(of: weekDay)!
        }
    }

    var month : Int {
        get {
            return Calendar.local.component(.month, from: self)
        }
    }

    var year : Int {
        get {
            return Calendar.local.component(.year, from: self)
        }
    }

    //MARK: Trim
    var trimmedTime : Date {
        get {
            //TODO : handle local time zone
            let calendar = Calendar.local

            let year = calendar.component(.year, from: self)
            let month = calendar.component(.month, from: self)
            let day = calendar.component(.day, from: self)

            let components = DateComponents(calendar: calendar, timeZone:TimeZone.zero(), year: year, month: month, day:day)
            return components.date!
        }
    }

    var trimmedDayAndTime : Date {
        get {
            let calendar = Calendar.local

            let year = calendar.component(.year, from: self)
            let month = calendar.component(.month, from: self)

            let components = DateComponents(calendar: calendar, timeZone:TimeZone.zero(), year: year, month: month)
            return components.date!
        }
    }

    //MARK: Format
    var weekDayShort : String {
        get {
            return DateUtility.shared.weekDayShortFormatter.string(from: self)
        }
    }

    var monthMedium: String {
        get {
            return DateUtility.shared.monthMediumFormatter.string(from: self).capitalized
        }
    }

    //MARK: Transform
    var yesterday: Date {
        get {
            return Calendar.local.date(byAdding: .day, value: -1, to: self)!
        }
    }

    var tomorrow: Date {
        get {
            return Calendar.local.date(byAdding: .day, value: 1, to: self)!
        }
    }

    var dateShort: String {
        return DateUtility.shared.dateShortFormatter.string(from: self)
    }
}

extension Calendar {
    static var local : Calendar {
        get {
            var calendar = Calendar.current
            calendar.locale = Locale.current
            return calendar
        }
    }

    static var common : Calendar {
        return Common.shared.calendar
    }

    //US: [0, 1, 2, 3, 4, 5, 6]
    //UA: [1, 2, 3, 4, 5, 6, 0]
    var orderedWeekDayIndexes : [Int] {
        get {
            var days = [Int]()
            var i = firstWeekday - 1
            for _ in (0..<7) {
                days.append(i)
                i = i == 6 ? 0 : i + 1
            }
            return days
        }
    }

    //US: [1, 2, 3, 4, 5, 6, 7]
    //UA: [2, 3, 4, 5, 6, 7, 1]
    var orderedWeekDays : [Int] {
        get {
            return [1, 2, 3, 4, 5, 6, 7][orderedWeekDayIndexes]
        }
    }

    var orderedWeekDaySymbols : [String] {
        get {
            return weekdaySymbols[orderedWeekDayIndexes]
        }
    }
}


