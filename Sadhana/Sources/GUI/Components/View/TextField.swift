//
//  TextField.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextField: UITextField {

    var deleteWhenEmpty : Driver<Void> {
        get {
            return deleteWhenEmptyInternal.asDriver(onErrorJustReturn: ())
        }
    }
    private let deleteWhenEmptyInternal = PublishSubject<Void>()

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true
        super.deleteBackward()
        if wasEmpty {
            deleteWhenEmptyInternal.onNext()
        }
    }
}
