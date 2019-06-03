//
//  DateUtilites.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/15/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


class DateUtility {
    static let shared = DateUtility()
    let localFormatter = DateFormatterService(timeZone:TimeZone.current)
    let globalFormatter = DateFormatterService(timeZone:TimeZone.zero)
}

class DateFormatterService {
    let weekDayShortFormatter = DateFormatter()
    let monthMediumFormatter = DateFormatter()
    let monthShortFormatter = DateFormatter()
    let dateShortFormatter = DateFormatter()

    init (timeZone:TimeZone) {
        weekDayShortFormatter.timeZone = timeZone
        weekDayShortFormatter.dateFormat = "E"

        monthMediumFormatter.timeZone = timeZone
        monthMediumFormatter.dateFormat = "LLLL YYYY"

        monthShortFormatter.timeZone = timeZone
        monthShortFormatter.dateFormat = "LLLL"

        dateShortFormatter.timeZone = timeZone
        dateShortFormatter.dateStyle = .medium
    }
}

extension Date {

    var isLast2Months : Bool {
        return Calendar.current.date(byAdding: .month, value: 2, to: self.trimmedDayAndTime)! > Date().trimmedDayAndTime
    }

    //MARK: Component
    var minute : Int {
        return Calendar.current.component(.minute, from: self)
    }

    var hour : Int {
        return Calendar.current.component(.hour, from: self)
    }

    var day : Int {
        return Calendar.current.component(.day, from: self)
    }

    var weekDay : Int {
        return Calendar.current.component(.weekday, from: self)
    }

    var weekDayIndex : Int {
        return Calendar.current.orderedWeekDays.index(of: weekDay)!
    }

    var month : Int {
        return Calendar.current.component(.month, from: self)
    }

    var year : Int {
        return Calendar.current.component(.year, from: self)
    }

    //MARK: Local
    var local : LocalDate {
        return LocalDate(global:self)
    }

    //MARK: Trim
    var trimmedDayAndTime : Date {
         let calendar = Calendar.global

         let year = calendar.component(.year, from: self)
         let month = calendar.component(.month, from: self)

         let components = DateComponents(calendar: calendar, year: year, month: month)
         return components.date!
    }

    //MARK: Format
    var weekDayShort : String {
        return DateUtility.shared.localFormatter.weekDayShortFormatter.string(from: self)
    }

    var monthMedium: String {
        return DateUtility.shared.localFormatter.monthMediumFormatter.string(from: self).capitalized
    }

    var monthShort: String {
        return DateUtility.shared.localFormatter.monthShortFormatter.string(from: self).capitalized
    }

    var dateShort: String {
        return DateUtility.shared.localFormatter.dateShortFormatter.string(from: self)
    }

    //MARK: Transform
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
}

extension Calendar {
    static var global : Calendar {
        return Common.shared.calendar
    }

    //US: [0, 1, 2, 3, 4, 5, 6]
    //UA: [1, 2, 3, 4, 5, 6, 0]
    var orderedWeekDayIndexes : [Int] {
        var days = [Int]()
        var i = firstWeekday - 1
        for _ in (0..<7) {
            days.append(i)
            i = i == 6 ? 0 : i + 1
        }
        return days
    }

    //US: [1, 2, 3, 4, 5, 6, 7]
    //UA: [2, 3, 4, 5, 6, 7, 1]
    var orderedWeekDays : [Int] {
        return [1, 2, 3, 4, 5, 6, 7][orderedWeekDayIndexes]
    }

    var orderedWeekDaySymbols : [String] {
        return weekdaySymbols[orderedWeekDayIndexes]
    }
}


class LocalDate : Comparable, Hashable {
    let year : Int
    let month : Int
    let day : Int

    var weekDay : Int {
        return date.weekDay
    }

    var weekDayIndex : Int {
        return date.weekDayIndex
    }

    lazy var date : Date = {
        let components = DateComponents(calendar: Calendar.global,
                                        year: year,
                                        month: month,
                                        day:day)
        return components.date!
    }()

    var isToday : Bool {
        return self == LocalDate()
    }

    //MARK: - Init
    convenience init() {
        self.init(global: Date())
    }

    init(local date: Date) {
        year = Calendar.global.component(.year, from: date)
        month = Calendar.global.component(.month, from: date)
        day = Calendar.global.component(.day, from: date)
    }

    init(global date: Date) {
        year = Calendar.current.component(.year, from: date)
        month = Calendar.current.component(.month, from: date)
        day = Calendar.current.component(.day, from: date)
    }

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    //MARK: Format
    var weekDayShort : String {
        return DateUtility.shared.globalFormatter.weekDayShortFormatter.string(from: date)
    }

    var monthMedium: String {
        return DateUtility.shared.globalFormatter.monthMediumFormatter.string(from: date).capitalized
    }

    var dateShort: String {
        return DateUtility.shared.globalFormatter.dateShortFormatter.string(from: date)
    }

    //MARK: - Trim
    var trimDay : LocalDate {
        return LocalDate(year: year, month: month, day: 1)
    }

    //MARK: - Add
    func add(years:Int) -> LocalDate {
        return LocalDate(local:Calendar.global.date(byAdding: .year, value: years, to: date)!)
    }

    func add(months:Int) -> LocalDate {
        return LocalDate(local:Calendar.global.date(byAdding: .month, value: months, to: date)!)
    }

    func add(weeks:Int) -> LocalDate {
        return LocalDate(local:Calendar.global.date(byAdding: .weekOfYear, value: weeks, to: date)!)
    }

    func add(days:Int) -> LocalDate {
        return LocalDate(local:Calendar.global.date(byAdding: .day, value: days, to: date)!)
    }

    var tomorrow : LocalDate {
        return add(days: 1)
    }

    var yesterday : LocalDate {
        return add(days: -1)
    }

    //MARK: - Compare
    public static func ==(lhs: LocalDate, rhs: LocalDate) -> Bool {
        return lhs.date == rhs.date
    }

    public static func <(lhs: LocalDate, rhs: LocalDate) -> Bool {
        return lhs.date < rhs.date
    }

    public static func <=(lhs: LocalDate, rhs: LocalDate) -> Bool {
        return lhs.date <= rhs.date
    }

    public static func >=(lhs: LocalDate, rhs: LocalDate) -> Bool {
        return lhs.date >= rhs.date
    }

    public static func >(lhs: LocalDate, rhs: LocalDate) -> Bool {
        return lhs.date > rhs.date
    }

    //MARK: - Hash
    public var hashValue: Int {
        return date.hashValue
    }
}


