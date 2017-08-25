//
//  OtherGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/22/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class OtherGraphVM : GraphVM {
    let firstPageRunning : Driver<Bool>
    let pageRunning = IndexedActivityIndicator()
    let pageDidUpdate = PublishSubject<Int>()
    let dataDidReload = PublishSubject<Void>()

    let userID : Int32

    init(_ userID : Int32) {
        self.userID = userID
        firstPageRunning = pageRunning.asDriver(for:0)
        super.init()

        //TODO: refactor using load() method
        refresh.subscribe(onNext: { [unowned self] () in
            Remote.service.loadEntries(for: userID)
                .track(self.pageRunning, index:0)
                .track(self.errors)
                .subscribe(onSuccess: { [unowned self] (page) in
                    self.reloadData()
                    self.entries.removeAll()
                    var monthDict = [Date: Entry]()
                    page.forEach({ (entry) in
                        monthDict[entry.date] = entry
                    })
                    self.entries[Date().trimmedDayAndTime] = monthDict
                    self.dataDidReload.onNext()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }

    override func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        let monthDate = date.trimmedDayAndTime
        var monthEntries = entries[monthDate]

        if indexPath.row > (numberOfRows(in: indexPath.section) - 10) {
            let nextSection = indexPath.section + 1
            if nextSection < numberOfSections {
                load(monthDate)
            }
        }

        return (monthEntries?[date], date)
    }

    func load(_ month:Date) {
        let sectionIndex = section(for: month)
        if !pageRunning.has(index: sectionIndex),
            entries[month] == nil {
            Remote.service.loadEntries(for: userID, month:month)
                .track(pageRunning, index:sectionIndex)
                .track(self.errors)
                .subscribe(onSuccess: { [unowned self] (page) in
                var monthDict = [Date: Entry]()
                 page.forEach({ (entry) in
                    monthDict[entry.date] = entry
                })
                self.entries[month] = monthDict
                self.pageDidUpdate.onNext(sectionIndex)
            }).disposed(by: disposeBag)
        }
    }
}
