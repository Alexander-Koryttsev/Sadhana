//
//  EditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

import Crashlytics

class EditingVM: BaseVM {
    unowned let router : EditingRouter
    let save = PublishSubject<Void>()
    let cancel = PublishSubject<Void>()
    let initialDate : Date
    let openingDate = Date()

    private let context = Local.service.newSubViewForegroundContext()

    var hasChanges : Bool {
        get {
            for entry in context.registeredObjects {
                if let entry = entry as? ManagedEntry {
                    if entry.dateUpdated > openingDate,
                        entry.shouldSynch {
                        return true
                    }
                }
            }
            return false
        }
    }

    init(_ router : EditingRouter, date:Date) {
        self.router = router
        initialDate =  (date <= Date() ? date : Date()).trimmedTime

        super.init()

        cancel.subscribe(onNext:{ [weak self] () in
            if self == nil { return }

            if self!.hasChanges {
                let alert = Alert()
                alert.add(action:"discardChanges".localized, style: .destructive, handler: { [weak self] () in
                    self?.router.hideSadhanaEditing()
                    Answers.logCustomEvent(withName: "Discard changes", customAttributes: nil)
                })

                alert.add(action: "cancel".localized, style: .cancel, handler: {
                    Answers.logCustomEvent(withName: "Cancel discarding changes", customAttributes: nil)
                })

                self!.alerts.onNext(alert)
            }
            else {
                self?.router.hideSadhanaEditing()
                Answers.logCustomEvent(withName: "Hide editing without changes", customAttributes: nil)
            }

        }).disposed(by: disposeBag)


        save.flatMap { [unowned self] () -> Observable<Bool> in
            var signals = [Observable<Bool>]()
            //TODO:filter
            //TODO:thread safe
            var entries = [ManagedEntry]()
            for entry in self.context.registeredObjects {
                if let entry = entry as? ManagedEntry {
                    if entry.dateCreated == entry.dateUpdated,
                        entry.ID == nil {
                        self.context.delete(entry)
                        continue
                    }
                    entries.append(entry)
                }
            }

            for entry in entries {
                if entry.shouldSynch {
                    let strongSelf = self
                    let signal = Remote.service.send(entry)
                        .subscribeOn(MainScheduler.instance)
                        .observeOn(MainScheduler.instance)
                        .do(onNext: { (ID) in
                            entry.ID = ID
                            entry.dateSynched = Date()
                            strongSelf.context.saveRecursive()
                        }, onError:{ (error) in
                            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: entry.json)
                        })
                        .track(self.errors)
                        .asBoolObservable()
                    signals.append(signal)
                }
            }

            self.context.saveRecursive()
            Answers.logCustomEvent(withName: "Save Entries", customAttributes: ["Hour": Date().hour])

            return Observable.merge(signals)
                    .observeOn(MainScheduler.instance)
                    .do(onCompleted:{
                        NotificationCenter.default.post(name: .local(.entriesDidSend), object: nil)
                    })
        }   .subscribe()
            .disposed(by: disposeBag)
    }

    func viewModelForEntryEditing(before vm: EntryEditingVM) -> EntryEditingVM {
        return viewModelForEntryEditing(for:vm.date.yesterday)
    }

    func viewModelForEntryEditing(after vm: EntryEditingVM) -> EntryEditingVM {
        return viewModelForEntryEditing(for:vm.date.tomorrow)
    }

    func viewModelForEntryEditing(for date: Date? = nil) -> EntryEditingVM {
        let date = date ?? initialDate
        return  EntryEditingVM(date: date, context: context, enabled: date <= Date())
    }
}
