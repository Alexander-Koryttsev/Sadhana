//
//  BaseVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa
import RxSwift

class BaseVM<Router> {
    let errorMessages = PublishSubject<String>()
    let errorMessagesUI: Driver<String>
    let errors = PublishSubject<Error>()
    let disposeBag = DisposeBag()
    let router:Router

    init(_ router:Router) {
        self.router = router
        self.errorMessagesUI = errorMessages.asDriver(onErrorJustReturn: "")
        self.setUp()
    }

    func setUp() {
        errors.subscribeOn(MainScheduler.instance)
        .subscribe(onNext:{[weak self] (error) in
            self?.handle(error:error)
        })
        .disposed(by: disposeBag)
    }

    func handle(error:Error) {
        switch error {
        case RemoteError.notLoggedIn:
            RootRouter.shared?.logOut(errorMessage:"Your session is expired")
            break
        case RemoteError.invalidRequest(_, let description):
            self.errorMessages.onNext(description)
            break
        default: break
        }
    }
}

extension ObservableType {
    func track(_ errors:PublishSubject<Error>) -> Observable<Self.E> {
        return self.do(onError:{(error) in
            errors.onNext(error)
        })
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    func track(_ errors:PublishSubject<Error>) -> Single<PrimitiveSequence.E> {
        return self.do(onError:{(error) in
            errors.onNext(error)
        })
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    func track(_ errors:PublishSubject<Error>) -> PrimitiveSequence<CompletableTrait, Element> {
        return self.do(onError:{(error) in
            errors.onNext(error)
        })
    }
}
