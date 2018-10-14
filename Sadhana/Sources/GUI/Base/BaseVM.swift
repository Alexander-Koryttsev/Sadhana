//
//  BaseVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



class BaseVM {
    let errors = PublishSubject<Error>()
    let messages = PublishSubject<String>()
    let alerts = PublishSubject<Alert>()
    let disposeBag = DisposeBag()
    var disappearBag = DisposeBag()

    lazy var tapticEngine = UINotificationFeedbackGenerator()
    lazy var messagesUI = {
        self.messages.asDriver(onErrorJustReturn: "")
    }()

    init() {
        errors.asDriver(onErrorJustReturn: GeneralError.error)
            .map{[weak self] (error) in self?.handle(error: error) ?? error.localizedDescription}
            .filter { $0.count > 0 }
            .drive(messages)
            .disposed(by: disposeBag)
    }

    func handle(error:Error) -> String {
        switch error {
        case RemoteErrorKey.notLoggedIn,
             RemoteErrorKey.restForbidden,
             RemoteErrorKey.invalidGrant:
            RootRouter.shared?.logOut(message: "error_session_expired".localized)
            return ""
        default:
            return error.localizedDescription
        }
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
    func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration {
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func select(_ indexPath: IndexPath) {}
}

extension ObservableType {
    func track(_ errors:PublishSubject<Error>) -> Observable<Self.E> {
        return self.do(onError:{(error) in
            errors.onNext(error)
        })
    }
}
