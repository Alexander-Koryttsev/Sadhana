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
    let done = PublishSubject<Void>()
    let cancel = PublishSubject<Void>()

    init(_ router : SadhanaEditingRouter) {
        self.router = router

        super.init()

        cancel.subscribe(onNext:{
            router.hideSadhanaEditing()
        }).disposed(by: disposeBag)

        done.subscribe(onNext:{
            router.hideSadhanaEditing()
        }).disposed(by: disposeBag)
    }
}
