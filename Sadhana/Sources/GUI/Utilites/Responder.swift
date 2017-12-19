//
//  Responder.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol Responder {
    var disposeBag : DisposeBag { get }

    var nextResponder : Responder { get set }
    var backResponder : Responder { get set }

    var goNextSubject : PublishSubject<Void> { get }
    var goBackSubject : PublishSubject<Void> { get }

    var becomeActiveSubject : PublishSubject<Void> { get }
    func becomeActive()
}

extension Responder where Self : UIResponder {
    func goNext() {
       // nextResponder.becomeActive()
    }

    func goBack() {
        backResponder.becomeActive()
    }

    func setUpResponder() {
      //  goNextSubject.subscribe(onNext: { [weak self] () in
       //     self?.goNext()
       // })
    }
}

protocol Container : Responder {
    var firstResponder : Responder { get set }
    var lastResponder : Responder { get set }
}
