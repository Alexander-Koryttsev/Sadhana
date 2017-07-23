//
//  SadhanaEditingVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift

class SadhanaEditingVM: BaseVM {
    let router : SadhanaEditingRouter
    let save = PublishSubject<Void>()
    let cancel = PublishSubject<Void>()
    let va = Variable()

    private let context = Local.service.newSubViewForegroundContext()

    init(_ router : SadhanaEditingRouter) {
        self.router = router

        super.init()

        cancel.subscribe(onNext:{
            router.hideSadhanaEditing()
        }).disposed(by: disposeBag)

        save.subscribe(onNext:{
            self.context.saveHandled()
        }).disposed(by: disposeBag)
    }

    func viewModelForEntryEditing(before vm: SadhanaEntryEditingVM) -> SadhanaEntryEditingVM? {
        return viewModelForEntryEditing(vm.date.yesterday)
    }

    func viewModelForEntryEditing(after vm: SadhanaEntryEditingVM) -> SadhanaEntryEditingVM? {
        return viewModelForEntryEditing(vm.date.tomorrow)
    }

    func viewModelForEntryEditing(_ forDate: Date? = Date()) -> SadhanaEntryEditingVM? {
        return forDate! <= Date() ? SadhanaEntryEditingVM(date: forDate!, context: context) : nil
    }
}
