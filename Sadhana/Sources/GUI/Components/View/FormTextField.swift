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
import EasyPeasy

class FormTextField: UITextField {
    private let disposeBag = DisposeBag()
    private var editingBag = DisposeBag()

    let resignActive = PublishSubject<Bool/*isNext*/>()
    let becomeActive = PublishSubject<Bool/*isNext*/>()

    override init(frame: CGRect) {

        super.init(frame: frame)

        rx.controlEvent(.editingDidBegin).asDriver().drive(onNext: { [unowned self] () in
            self.selectAll(nil)
            KeyboardManager.shared.showBackNextButtons = true
            KeyboardManager.shared.backButton.rx.tap.asDriver().map{return false}.drive(self.resignActive).disposed(by: self.editingBag)
            KeyboardManager.shared.nextButton.rx.tap.asDriver().map{return true}.drive(self.resignActive).disposed(by: self.editingBag)
        }).disposed(by: disposeBag)

        rx.controlEvent(.editingDidEnd).asDriver().drive(onNext: { [unowned self] () in
            self.editingBag = DisposeBag()
        }).disposed(by: disposeBag)

        becomeActive.subscribe(onNext: { [weak self] (_) in
            _ = self?.becomeFirstResponder()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true
        super.deleteBackward()
        if wasEmpty {
            resignActive.onNext(false)
        }
    }
}


