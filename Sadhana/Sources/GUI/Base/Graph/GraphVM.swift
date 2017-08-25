//
//  GraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxSwift
import RxCocoa

class GraphVM : BaseVM {

    let refresh = PublishSubject<Void>()
    
    private var maxCounts = [Int : Int16]()
    var entries = [Date : [Date : Entry]]()

    var numberOfSections : Int {
        get {
            return Common.shared.calendarDates.count
        }
    }

    func reloadData() {
        maxCounts.removeAll()
    }

    func numberOfRows(in section:Int) -> Int {
        return Common.shared.calendarDates[section].count
    }

    func title(for section:Int) -> String {
        return Common.shared.calendarDates[section].first!.monthMedium
    }

    func monthDate(for section:Int) -> Date {
        return Common.shared.calendarDates[section].first!.trimmedDayAndTime
    }

    func section(for monthDate:Date) -> Int {
        var index = 0
        for section in Common.shared.calendarDates {
            if section.first!.trimmedDayAndTime == monthDate {
                return index
            }
            index += 1
        }

        return index
    }

    func date(at indexPath:IndexPath) -> Date {
        return Common.shared.calendarDates[indexPath.section][indexPath.row]
    }

    func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        return (nil, date)
    }

    func entries(for monthDate:Date) -> [Date : Entry] {
        return entries[monthDate] ?? [:]
    }

    func entries(for section:Int) -> [Entry] {
        return Array(entries(for:monthDate(for: section)).values)
    }

    func maxCount(for section:Int) -> Int16 {
         if let cachedCount = maxCounts[section] {
            return cachedCount
         }
         let maxCount = entries(for: section).reduce(16, { (result, entry) -> Int16 in
         let sum = entry.japaSum
            return sum > result ? sum : result
         })
         maxCounts[section] = maxCount
         return maxCount
    }
}
