//
//  LoginVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa

import Alamofire

enum LoginErrorMessage: String {
    case invalidCredentials = "Invalid credentials"
}

class LoginVM : BaseVM {
    let login = Variable(Config.defaultLogin)
    let password = Variable(Config.defaultPassword)
    let tap = PublishSubject<Void>()
    let canSignIn: Driver<Bool>
    let taptic = UINotificationFeedbackGenerator()

    private let running = ActivityIndicator()

    let activityIndicator: Driver<Bool>

    override init() {
        canSignIn = Observable.combineLatest(login.asObservable(), password.asObservable(), running.asObservable()) { (loginValue, passwordValue, running) in
            return !loginValue.isEmpty && !passwordValue.isEmpty && !running
        }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        activityIndicator = running.asDriver()

        super.init()

        tap.withLatestFrom(canSignIn)
            .filter{ $0 }
            .flatMap { [unowned self] _ -> Observable<Bool> in
                return Main.service.login(self.login.value, password: self.password.value)
                    .observeOn(MainScheduler.instance)
                    .flatMap { [unowned self] (user) -> Single<[ManagedEntry]> in
                        self.taptic.notificationOccurred(.success)
                        self.messages.onNext(String(format: "login_welcome".localized, user.name))
                        return Main.service.loadMyEntries()
                    }
                    .observeOn(MainScheduler.instance)
                    .map { _ -> Bool in
                        RootRouter.shared?.commitSignIn()
                        return true
                    }
                    .track(self.errors)
                    .track(self.running)
                    .catchErrorJustReturn(false)
                    .do(onNext:{ [unowned self] success in
                        self.taptic.notificationOccurred(success ? .success : .error)
                    })
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    @objc func register() {
        RootRouter.shared?.showRegistration()
    }
}
