//
//  LoginVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxSwift

class LoginVM {
    let login = Variable("")
    let password = Variable("")
    let tap = PublishSubject<Void>()
    let canSignIn: Observable<Bool>
    let router:RootRouter
    
    init(router:RootRouter) {
        self.router = router
        canSignIn = Observable.combineLatest(login.asObservable(), password.asObservable()) { (loginValue, passwordValue) in
            return !loginValue.isEmpty && !passwordValue.isEmpty
        }.distinctUntilChanged()
        
        _ = tap.withLatestFrom(canSignIn).filter({ (flag) -> Bool in
            return flag;
        })
            .subscribe(onNext: { [weak self] (flag) in
            if self == nil { return }
            let signIn = Remote.service.login(name: self!.login.value, password: self!.password.value)
            let loadUser = Remote.service.loadCurrentUser()
                
            _ = signIn.concat(loadUser)
                .flatMap({ (user) -> Single<LocalUser> in
                return Local.service.backgroundContext.save(user)
            }).subscribe(onSuccess: { [weak self] (user) in
                self?.router.commitSignIn()
            }, onError: { (error) in
                print(error)
            })
        })
    }
}
