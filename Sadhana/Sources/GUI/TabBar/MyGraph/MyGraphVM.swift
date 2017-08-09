//
//  MyGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa
import RxSwift
import CoreData
import Foundation

class MyGraphVM: GraphVM {
    let running = ActivityIndicator()
    let refresh = PublishSubject<Void>()
    private let router: MyGraphRouter
    private var entries = [Date : [Date : Entry]]()

    init(_ router: MyGraphRouter) {
        self.router = router

        super.init()

        //TODO: check first fetch (table view is empty on launch

        let loadNewEntries = loadEntries().asBoolObservable()
        refresh.flatMap({ return loadNewEntries })
            .subscribe()
            .disposed(by: disposeBag)


        Observable.of(loadEntries(),
                      loadEntries(monthAgo:1),
                      loadEntries(monthAgo:2))
            .merge()
            .subscribe()
            .disposed(by: disposeBag)
    }

    override func reloadData() {
        super.reloadData()
        entries.removeAll()
    }

    func loadEntries(month:Date? = nil, monthAgo:Int? = 0) -> Single<[ManagedEntry]> {
        return Single.create { [weak self] (observer) -> Disposable in
            if self == nil {
                observer(.error(GeneralError.noSelf))
                return Disposables.create{}
            }

            let calendar = Calendar.local
            let yearValue = calendar.component(.year, from: month ?? Date())
            let monthValue = calendar.component(.month, from: month ?? Date()) - monthAgo!
            let context = Local.service.viewContext

            return Remote.service.loadSadhanaEntries(userID: Local.defaults.userID!, year: yearValue, month: monthValue)
                .flatMap { (remoteEntries) -> Single<[ManagedEntry]> in
                    return context.rxSave(remoteEntries)
                }
                .track(self!.errors)
                .track(self!.running)
                .subscribe(observer)
        }
    }

    override func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        let monthDate = date.trimmedDayAndTime
        var month = entries[monthDate]
        if month == nil {
            month = [Date: Entry]()
            Local.service.viewContext.fetch(entriesFrom: monthDate).forEach({ (entry) in
                month![entry.date] = entry
            })
            entries[monthDate] = month!
        }

        return (month![date], date)
    }

    override func entries(for section:Int) -> [Entry] {
        return entries[monthDate(for: section)]!.values.map({ (entry) -> Entry in
            return entry
        })
    }
}

/*
 Local.service.viewContext.perform {
 let entry = Local.service.viewContext.create(ManagedEntry.self)
 entry.ID = Int32(arc4random_uniform(UInt32(INT32_MAX)))
 entry.dateCreated = Date()
 entry.dateUpdated = Date()
 entry.userID = Local.defaults.userID!
 entry.date = Date()

 entry.month = DateUtilities.monthFrom(date: Date())
 entry.japaCount7_30 = Int16(arc4random_uniform(16))
 entry.japaCount10 = Int16(arc4random_uniform(16))
 entry.japaCount18 = Int16(arc4random_uniform(16))
 entry.japaCount24 = Int16(arc4random_uniform(16))
 entry.reading = 0
 entry.kirtan = false
 entry.bedTime = nil
 entry.wakeUpTime = nil
 entry.exercise = false
 entry.service = true
 entry.lections = false

 do {
 try Local.service.viewContext.save()
 observer(.completed)
 }
 catch {
 observer(.error(error))
 }
 }

 return Disposables.create{}

 }*/
