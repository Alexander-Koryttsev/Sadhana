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

    private var dates = [[Date]]()
    private var maxCounts = [Int : Int16]()
    var numberOfSections : Int {
        get {
            return dates.count
        }
    }

    func reloadData() {
        dates.removeAll()
        var month = [Date]()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.create()
        calendar.enumerateDates(startingAfter: Date(), matching: DateComponents(hour:0, minute:0), matchingPolicy: .strict, direction: .backward, using: { (date, exactMatch, stop) in

            guard let date = date else { return }
            month.append(date)

            if calendar.component(.day, from: date) == 1,
                month.count > 0 {
                dates.append(month)
                month.removeAll()
            }

            stop = dates.count == 24
        });
        maxCounts.removeAll()
    }

    func numberOfRows(in section:Int) -> Int {
        return dates[section].count
    }

    func title(for section:Int) -> String {
        return dates[section].first!.monthMedium
    }

    func monthDate(for section:Int) -> Date {
        return dates[section].first!.trimmedDayAndTime
    }

    func date(at indexPath:IndexPath) -> Date {
        return dates[indexPath.section][indexPath.row]
    }

    func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        return (nil, date)
    }

    func entries(for section:Int) -> [Entry] {
        return []
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
