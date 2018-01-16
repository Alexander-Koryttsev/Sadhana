//
//  TextField.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

import RxCocoa
import EasyPeasy

class TextField: UITextField, Responsible, UITextFieldDelegate {
    fileprivate let disposeBag = DisposeBag()

    let goBack = PublishSubject<Void>()
    let goNext = PublishSubject<Void>()
    let becomeActive = PublishSubject<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        becomeActive.subscribe(onNext: { [weak self] (_) in
            _ = self?.becomeFirstResponder()
        }).disposed(by: disposeBag)

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true
        super.deleteBackward()
        if wasEmpty {
            goBack.onNext(())
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.goNext.onNext(())
        }
        return true
    }
}

class NumberField: TextField {
    private var editingBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        rx.controlEvent(.editingDidBegin).asDriver().drive(onNext: { [unowned self] () in
            self.selectAll(nil)
            KeyboardManager.shared.showBackNextButtons = true
            KeyboardManager.shared.backButton.rx.tap.bind(to:self.goBack).disposed(by: self.editingBag)
            KeyboardManager.shared.nextButton.rx.tap.bind(to:self.goNext).disposed(by: self.editingBag)
        }).disposed(by: disposeBag)

        rx.controlEvent(.editingDidEnd).asDriver().drive(onNext: { [unowned self] () in
            self.editingBag = DisposeBag()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


