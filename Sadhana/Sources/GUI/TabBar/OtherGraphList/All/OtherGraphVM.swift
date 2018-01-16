//
//  OtherGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/22/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa


class OtherGraphVM : GraphVM {
    let firstPageRunning : Driver<Bool>
    let pageRunning = IndexedActivityIndicator()
    let pageDidUpdate = PublishSubject<Int>()
    let dataDidReload = PublishSubject<Void>()
    let info : UserBriefInfo

    init(_ info:UserBriefInfo) {
        self.info = info
        firstPageRunning = pageRunning.asDriver(for:0)
        super.init()

        refresh.flatMap { [unowned self] _ in
            self.load(pageIndex: 0).do(onNext:{ [unowned self] (page) in
                self.reloadData()
                self.entries.removeAll()
                self.map(page: page, index: 0)
                self.dataDidReload.onNext(())
            }).concat(self.load(pageIndex: 1).do(onNext:{ [unowned self] (page) in
                self.handle(page: page, index: 1)
            }))
        }   .subscribe()
            .disposed(by: disposeBag)
    }

    override func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        let monthDate = date.trimmedDayAndTime
        var monthEntries = entries[monthDate]

        if indexPath.row > (numberOfRows(in: indexPath.section) - 10) {
            let nextSection = indexPath.section + 2
            if nextSection < numberOfSections {
                load(pageIndex: nextSection).subscribe(onSuccess: { [unowned self] (page) in
                    self.handle(page: page, index: nextSection)
                }).disposed(by:disposeBag)
            }
        }

        return (monthEntries?[date], date)
    }

    func handle(page: [Entry], index: Int) {
        self.map(page: page, index: index)
        self.pageDidUpdate.onNext(index)
    }

    func map(page: [Entry], index: Int) {
        var monthDict = [Date: Entry]()
        page.forEach({ (entry) in
            monthDict[entry.date] = entry
        })
        self.entries[Calendar.common.date(byAdding: .month, value: -index, to: Date().trimmedDayAndTime)!] = monthDict
    }

    func load(pageIndex:Int) -> Single<[Entry]> {
        let month = Calendar.common.date(byAdding: .month, value: -pageIndex, to:Date().trimmedDayAndTime)!
        return Remote.service.loadEntries(for: info.userID, month: month)
            .track(pageRunning, index: pageIndex)
            .track(errors)
    }
}
