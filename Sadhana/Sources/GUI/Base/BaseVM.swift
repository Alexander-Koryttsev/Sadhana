//
//  BaseVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa

class BaseVM {
    let errorMessages : Driver<String>
    let errors = PublishSubject<Error>()
    let messages = PublishSubject<String>()
    var messagesUI : Driver<String>
    let alerts = PublishSubject<Alert>()
    let disposeBag = DisposeBag()
    var disappearBag = DisposeBag()

    init() {
        messagesUI = messages.asDriver(onErrorJustReturn: "")
        
        errorMessages = errors.asDriver(onErrorJustReturn: GeneralError.error)
            .map({ (error) -> String in
                switch error {
                case RemoteError.notLoggedIn:
                    let message = "error_session_expired".localized
                    RootRouter.shared?.logOut(error:error)
                    return message
                case RemoteError.invalidRequest(_, let description):
                    return description
                default:
                    return error.localizedDescription
                }
            }).asSharedSequence()
        
        errorMessages.drive().disposed(by: disposeBag)
    }
}

class BaseTableVM : BaseVM {

    var numberOfSections : Int {
        return 0
    }

     func numberOfRows(in section: Int) -> Int {
        return 0
    }

    @available(iOS 11.0, *)
    func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let configuration = UISwipeActionsConfiguration(actions: [])
        return configuration
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
    func track(errors:PublishSubject<Error>) -> Single<PrimitiveSequence.E> {
        return self.do(onError:{(error) in
            errors.onNext(error)
        })
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    func track(_ errors:PublishSubject<Error>) -> Completable {
        return self.asObservable().do(onError:{(error) in
            errors.onNext(error)
        }).completable()
    }
}
