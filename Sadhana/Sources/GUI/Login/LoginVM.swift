//
//  LoginVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa
import RxSwift
import Alamofire

enum LoginErrorMessage: String {
    case invalidCredentials = "Invalid credentials"
}

class LoginVM : BaseVM<RootRouter> {
    let login = Variable("")
    let password = Variable("")
    let tap = PublishSubject<Void>()
    let canSignIn: Driver<Bool>
    private let running = ActivityIndicator()

    override init(_ router:RootRouter) {
        canSignIn = Observable.combineLatest(login.asObservable(), password.asObservable(), running.asObservable()) { (loginValue, passwordValue, running) in
            return !loginValue.isEmpty && !passwordValue.isEmpty && !running
        }.distinctUntilChanged().asDriver(onErrorJustReturn: false)

        super.init(router)
    }

    override func setUp() -> Void {
        super.setUp()

        let loginAction = Single<LocalUser>.create { [weak self] (observer) in
            if self == nil {
                observer(.error(GeneralError.noSelf))
                return Disposables.create{}
            }

            return Remote.service.login(name: self!.login.value, password: self!.password.value)
            .concat(Remote.service.loadCurrentUser())
            .flatMap { (user) in
                return Local.service.backgroundContext.save(user:user)
            }
            .track(self!.errors)
            .track(self!.running)
            .subscribe(observer)
        }

        tap.withLatestFrom(canSignIn)
        .filter({ (flag) -> Bool in return flag })
        .subscribe( onNext: { [weak self] (_) in
            if self == nil { return }
            loginAction.observeOn(MainScheduler.instance)
            .subscribe(onSuccess:{ [weak self] (user) in
                Local.defaults.userID = user.ID
                self?.router.commitSignIn()
            })
            .disposed(by: self!.disposeBag)
        })
        .disposed(by: disposeBag)
    }

}
