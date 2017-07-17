//
//  MySadhanaVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa
import RxSwift
import CoreData

class MySadhanaVM: BaseVM<MySadhanaRouter> {
    let frc = Local.service.viewContext.mySadhanaEntriesFRC()
    let running = ActivityIndicator()
    let refresh = PublishSubject<Void>()
    let endOfList = PublishSubject<Void>()

    override init(_ router: MySadhanaRouter) {
        super.init(router)
    }

    override func setUp() {
        super.setUp()

        do { try frc.performFetch() }
        catch { print(error) }

        refresh.subscribe(onNext:{ [weak self] () in
            if self == nil { return }
            self!.loadEntries().subscribe()
            .disposed(by: self!.disposeBag)
        })
        .disposed(by: disposeBag)

        endOfList.withLatestFrom(running.asObservable())
        .filter { (running) -> Bool in return !running}
        .subscribe(onNext: { [weak self] _ in
            guard self != nil,
            let entry = self?.frc.sections?.last?.objects?.first as? LocalSadhanaEntry else { return }
            self!.loadEntries(month:entry.month, monthAgo:1).subscribe()
            .disposed(by: self!.disposeBag)
        })
        .disposed(by: disposeBag)


        Observable.of(loadEntries(),
                      loadEntries(monthAgo:1),
                      loadEntries(monthAgo:2))
            .merge()
            .subscribe()
            .disposed(by: disposeBag)
    }

    func loadEntries(month:Date? = nil, monthAgo:Int? = 0) -> Single<[LocalSadhanaEntry]> {
        return Single.create { [weak self] (observer) -> Disposable in
            if self == nil {
                observer(.error(GeneralError.noSelf))
                return Disposables.create{}
            }

            let calendar = Calendar.current
            let yearValue = calendar.component(.year, from: month ?? Date())
            let monthValue = calendar.component(.month, from: month ?? Date()) - monthAgo!
            let context = Local.service.newSubViewBackgroundContext()

            return Remote.service.loadSadhanaEntries(userID: Local.defaults.userID!, year: yearValue, month: monthValue)
                .flatMap { (remoteEntries) -> Single<[LocalSadhanaEntry]> in
                    return context.save(remoteEntries)
                }
                .track(self!.errors)
                .track(self!.running)
                .subscribe(observer)
        }
    }
}

/*
 Local.service.viewContext.perform {
 let entry = Local.service.viewContext.create(LocalSadhanaEntry.self)
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
