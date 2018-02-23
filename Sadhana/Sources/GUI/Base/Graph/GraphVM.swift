//
//  GraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//




class GraphVM : BaseTableVM {

    let refresh = PublishSubject<Void>()
    
    let firstPageRunning : Driver<Bool>
    let pageRunning = IndexedActivityIndicator()
    let pageDidUpdate = PublishSubject<Int>()
    let dataDidReload = PublishSubject<Void>()
    let info : UserBriefInfo
    var shouldShowHeader: Bool {
        return true
    }
    var favorite : Bool {
        get {
            return Main.service.currentUser!.containsFavorite(with: info.userID)
        }
    }
    
    private var maxCounts = [Int : Int16]()
    var entries = [Date : [Date : Entry]]()
    
    init(_ info:UserBriefInfo) {
        self.info = info
        firstPageRunning = pageRunning.asDriver(for:0)
        super.init()
    }

    func toggleFavorite() {
        if let user = Main.service.currentUser!.favorite(with: info.userID) {
            user.removeFromFavorites()
        }
        else {
            Main.service.currentUser!.add(favorite: info)
            _ = Local.service.viewContext.rxSave(entries(for: 0)).subscribe()
        }
    }

    func clearData() {
        maxCounts.removeAll()
        entries.removeAll()
    }

    func reloadData() {

    }

    override var numberOfSections : Int {
        return Common.shared.calendarDates.count
    }

    override func numberOfRows(in section:Int) -> Int {
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
