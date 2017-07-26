//
//  EditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift

class EditingVM: BaseVM {
    let router : EditingRouter
    let save = PublishSubject<Void>()
    let cancel = PublishSubject<Void>()
    let va = Variable()

    private let context = Local.service.newSubViewForegroundContext()

    init(_ router : EditingRouter) {
        self.router = router

        super.init()

        cancel.subscribe(onNext:{
            router.hideSadhanaEditing()
        }).disposed(by: disposeBag)

        save.subscribe(onNext:{
            self.context.saveHandled()
        }).disposed(by: disposeBag)
    }

    func viewModelForEntryEditing(before vm: EntryEditingVM) -> EntryEditingVM? {
        return viewModelForEntryEditing(vm.date.yesterday)
    }

    func viewModelForEntryEditing(after vm: EntryEditingVM) -> EntryEditingVM? {
        return viewModelForEntryEditing(vm.date.tomorrow)
    }

    func viewModelForEntryEditing(_ forDate: Date? = Date()) -> EntryEditingVM? {
        return forDate! <= Date() ? EntryEditingVM(date: forDate!, context: context) : nil
    }
}
