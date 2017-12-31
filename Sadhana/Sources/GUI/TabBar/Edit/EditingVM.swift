//
//  EditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift
import Crashlytics

class EditingVM: BaseVM {
    let router : EditingRouter
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
        initialDate = date.trimmedTime

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

        save.subscribe(onNext:{ [weak self] () in
            if self == nil { return }
            var signals = [Observable<Bool>]()
            //TODO:filter
            //TODO:thread safe
            var entries = [ManagedEntry]()
            for entry in self!.context.registeredObjects {
                if let entry = entry as? ManagedEntry {
                    if entry.dateCreated == entry.dateUpdated,
                        entry.ID == nil {
                        self!.context.delete(entry)
                        continue
                    }
                    entries.append(entry)
                }
            }

            for entry in entries {
                if entry.shouldSynch {
                    let strongSelf = self!
                    let signal : Single<Int32?> = Remote.service.send(entry).do(onNext: { (ID) in
                        entry.ID = ID
                        entry.dateSynched = Date()
                        strongSelf.context.saveRecursive()
                    })
                    signals.append(signal
                        .track(self!.errors)
                        .asBoolObservable())
                }
            }

            self!.context.saveRecursive()
            _ = Observable.merge(signals).subscribe()

            var attributes = [String:String]()
            entries.forEach({ (entry) in
                attributes[entry.date.remoteDateString()] = (entry.ID != nil) ? entry.ID!.description : ""
            })
            
            Answers.logCustomEvent(withName: "Save Entries", customAttributes: attributes)
        })
            .disposed(by: disposeBag)
    }

    func viewModelForEntryEditing(before vm: EntryEditingVM) -> EntryEditingVM? {
        return viewModelForEntryEditing(for:vm.date.yesterday)
    }

    func viewModelForEntryEditing(after vm: EntryEditingVM) -> EntryEditingVM? {
        return viewModelForEntryEditing(for:vm.date.tomorrow)
    }

    func viewModelForEntryEditing(for date: Date? = nil) -> EntryEditingVM? {
        let date = date ?? initialDate
        return date <= Date() ? EntryEditingVM(date: date, context: context) : nil
    }
}
