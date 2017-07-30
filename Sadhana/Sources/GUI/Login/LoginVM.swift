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

class LoginVM : BaseVM {
    let login = Variable("")
    let password = Variable("")
    let tap = PublishSubject<Void>()
    let canSignIn: Driver<Bool>

    private let running = ActivityIndicator()

    var activityIndicator: Driver<Bool> { get {
            return running.asDriver()
        }
    }

    override init() {
        canSignIn = Observable.combineLatest(login.asObservable(), password.asObservable(), running.asObservable()) { (loginValue, passwordValue, running) in
            return !loginValue.isEmpty && !passwordValue.isEmpty && !running
        }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        super.init()

        tap.withLatestFrom(canSignIn)
            .filter({ (flag) -> Bool in return flag })
            .flatMap { [weak self] _ -> Observable<Bool> in
                if self == nil { return Observable.just(false) }
                return Remote.service.login(name: self!.login.value, password: self!.password.value)
                    .concat(Remote.service.loadCurrentUser().asObservable())
                    .flatMap { (user) -> Observable<ManagedUser> in
                        return Local.service.backgroundContext.rxSave(user:user).asObservable()
                    }
                    .observeOn(MainScheduler.instance)
                    .map({ (user) -> Bool in
                        Local.defaults.userID = user.ID
                        RootRouter.shared?.commitSignIn()
                        return true
                    })
                    .track(self!.errors)
                    .track(self!.running)
                    .catchErrorJustReturn(false)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
