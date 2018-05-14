//
//  EditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



import Crashlytics

class EditingVM: BaseVM {
    unowned let router : EditingRouter
    let initialDate : LocalDate
    let openingDate = Date()

    private let context = Local.service.newSubViewForegroundContext()

    init(_ router : EditingRouter, date:LocalDate) {
        self.router = router
        initialDate =  (date <= LocalDate() ? date : LocalDate())

        super.init()
    }

    var hasUnsavedChanges : Bool {
        get {
            for entry in context.registeredObjects {
                if let entry = entry as? ManagedEntry {
                    if entry.dateUpdated == entry.dateCreated {
                        //New
                        if !entry.empty,
                            entry.dateSynched == nil {
                            return true
                        }
                    }
                    else {
                        //Updated
                        if entry.hasPersistentChangedValues {
                            return true
                        }
                    }
                }
            }
            return false
        }
    }

    @objc func cancel() {
        if self.hasUnsavedChanges {
            let alert = Alert()
            alert.add(action:"discard_changes".localized, style: .destructive, handler: { [weak self] () in
                self!.router.hideSadhanaEditing()
                Answers.logCustomEvent(withName: "Discard changes", customAttributes: nil)
            })

            alert.add(action: "cancel".localized, style: .cancel, handler: {
                Answers.logCustomEvent(withName: "Cancel discarding changes", customAttributes: nil)
            })

            self.alerts.onNext(alert)
        }
        else {
            self.router.hideSadhanaEditing()
            Answers.logCustomEvent(withName: "Hide editing without changes", customAttributes: nil)
        }
    }

    @objc func save() {
        for entry in self.context.registeredObjects {
            if let entry = entry as? ManagedEntry {
                if entry.empty {
                    self.context.delete(entry)
                }
                else if entry.isUpdated {
                    entry.dateUpdated = Date()
                }
            }
        }

        self.context.saveHandledRecursive()
        Answers.logCustomEvent(withName: "Save Entries", customAttributes: ["Hour": Date().hour])
    }
    
    func viewModelForEntryEditing(before vm: EntryEditingVM) -> EntryEditingVM {
        return viewModelForEntryEditing(for:vm.date.add(days: -1))
    }

    func viewModelForEntryEditing(after vm: EntryEditingVM) -> EntryEditingVM {
        return viewModelForEntryEditing(for:vm.date.add(days: 1))
    }

    func viewModelForEntryEditing(for date: LocalDate? = nil) -> EntryEditingVM {
        let date = date ?? initialDate
        return  EntryEditingVM(date: date, context: context, enabled: date <= LocalDate())
    }
}
