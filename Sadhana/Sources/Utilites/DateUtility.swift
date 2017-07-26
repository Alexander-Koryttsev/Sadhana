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

    //MARK: Component
    var minute : Int {
        get {
            return Calendar.current.component(.minute, from: self)
        }
    }

    var hour : Int {
        get {
            return Calendar.current.component(.hour, from: self)
        }
    }

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

    //MARK: Trim
    var trimmedTime : Date {
        get {
            //TODO : handle local time zone
            let calendar = Calendar.current

            let year = calendar.component(.year, from: self)
            let month = calendar.component(.month, from: self)
            let day = calendar.component(.day, from: self)

            let components = DateComponents(calendar: calendar, timeZone:TimeZone.create(), year: year, month: month, day:day)
            return components.date!
        }
    }

    var trimmedDayAndTime : Date {
        get {
            let calendar = Calendar.current

            let year = calendar.component(.year, from: self)
            let month = calendar.component(.month, from: self)

            let components = DateComponents(calendar: calendar, timeZone:TimeZone.create(), year: year, month: month)
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
            return Calendar.current.date(byAdding: .day, value: -1, to: self)!
        }
    }

    var tomorrow: Date {
        get {
            return Calendar.current.date(byAdding: .day, value: 1, to: self)!
        }
    }
}
