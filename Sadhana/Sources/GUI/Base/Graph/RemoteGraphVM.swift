//
//  RemoteGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/22/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//





class RemoteGraphVM : GraphVM {
    override init(_ info:UserBriefInfo) {
        super.init(info)

        refresh.flatMap { [unowned self] _ in
            self.load(pageIndex: 0).do(onSuccess:{ [unowned self] (page) in
                self.clearData()
                self.map(page: page, index: 0)
                self.dataDidReload.onNext(())
            }).concat(self.load(pageIndex: 1).do(onSuccess:{ [unowned self] (page) in
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
            if nextSection < numberOfSections,
                !pageRunning.has(index: nextSection),
                 entries[self.monthDate(for: nextSection)] == nil {
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
        entries[monthDate(for: index)] = monthDict
    }

    func load(pageIndex:Int) -> Single<[Entry]> {
        return Remote.service.loadEntries(for: info.userID, month: monthDate(for: pageIndex))
            .track(pageRunning, index: pageIndex)
            .track(errors)
    }
}
