//
//  MyGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa

import CoreData
import Foundation

class MyGraphVM: GraphVM {
    let running = ActivityIndicator()
    let select = PublishSubject<IndexPath>()
    let settings = PublishSubject<Void>()
    private unowned let router: MyGraphRouter

    private let updateSectionInternal = PublishSubject<Int>()
    let updateSection : Driver<Int>

    init(_ router: MyGraphRouter) {
        self.router = router
        updateSection = updateSectionInternal.asDriver(onErrorJustReturn: 0)

        super.init()

        let loadNewEntries = loadMyEntries().asDriver(onErrorJustReturn: [])
        refresh.flatMap({ return loadNewEntries })
            .subscribe()
            .disposed(by: disposeBag)

        select.subscribe(onNext:{ [unowned self] (indexPath) in
            self.router.showSadhanaEditing(date: self.date(at: indexPath))
        }).disposed(by: disposeBag)
    }

    override func reloadData() {
        super.reloadData()
        entries.removeAll()
    }

    func loadMyEntries() -> Single<[ManagedEntry]> {
        return Single.create { [unowned self] (observer) -> Disposable in
            return Main.service.loadMyEntries()
                .do(onNext: {[weak self] (_) in
                    self?.reloadData()
                })
                .track(self.errors)
                .track(self.running)
                .subscribe(observer)
        }
    }

    override func entries(for monthDate:Date) -> [Date : Entry] {
        var month = entries[monthDate]
        if month == nil {
            month = [Date: Entry]()
            Local.service.viewContext.fetch(entriesFrom: monthDate).forEach({ (entry) in
                month![entry.date] = entry
            })

            entries[monthDate] = month!
        }
        return month!
    }

    override func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        var month = entries(for: date.trimmedDayAndTime)

        return (month[date], date)
    }

    @objc func showSettings() {
        router.showSettings()
    }
}
