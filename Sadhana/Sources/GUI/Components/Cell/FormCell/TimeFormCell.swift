//
//  DateFormCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/20/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy
import RxCocoa
import RxSwift

class TimeKeyboardFormCell: CountsLayoutCell, UITextFieldDelegate {
    private let viewModel: TimeFieldVM
    private var hoursView: CountView {
        get {
            return countViews.first!
        }
    }
    private var minutesView: CountView {
        get {
            return countViews.last!
        }
    }

    init(_ viewModel: TimeFieldVM) {
        self.viewModel = viewModel
        super.init(fieldsCount:2)

        if let value = viewModel.variable.value {
            if value.rawValue != 0 || viewModel.optional {
                hoursView.valueField.text = value.hour.description
                minutesView.valueField.text = value.minute.description
            }
        }

        titleLabel.text = viewModel.key.localized

        setUp(field: hoursView.valueField)
        hoursView.valueField.deleteWhenEmpty.drive(goBack).disposed(by: disposeBag)
        hoursView.titleLabel.text = "hours".localized

        setUp(field: minutesView.valueField)
        minutesView.valueField.deleteWhenEmpty.asObservable().subscribe(onNext: {
            _ = self.hoursView.valueField.becomeFirstResponder()
        }).disposed(by: disposeBag)

        minutesView.titleLabel.text = "minutes".localized

        Observable.combineLatest(hoursView.valueField.rx.textRequired.asDriver().asObservable().skip(1), minutesView.valueField.rx.textRequired.asDriver().asObservable().skip(1)).map({ (hours, minutes) -> Time? in
            if !self.viewModel.optional {
                return Time(hour:hours.isEmpty ? "0" : hours, minute:minutes.isEmpty ? "0" : minutes)
            }
            return Time(hour:hours, minute:minutes)
        })
            .bind(to: viewModel.variable)
            .disposed(by: viewModel.disposeBag)
    }

    func setUp(field:UITextField) {
        field.delegate = self
        field.placeholder = "00"
    }

    override func becomeFirstResponder() -> Bool {
        let field = (hoursView.valueField.text?.isEmpty ?? true) ? hoursView.valueField : minutesView.valueField
        return field.becomeFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        if let resultString = nsString?.replacingCharacters(in: range, with: string) {
            if resultString.isEmpty {
                return true
            }

            if resultString.characters.count > 2  {
                return false
            }

            if let number = Int(resultString) {
                if textField == hoursView.valueField,
                    (0..<24).contains(number) {
                    if number > 2 ||
                        resultString.characters.count == 2 {
                        DispatchQueue.main.async {
                            self.minutesView.valueField.becomeFirstResponder()
                        }
                    }
                    return true
                }
                if textField == minutesView.valueField,
                    (0..<60).contains(number) {
                    if number > 5 ||
                        resultString.characters.count == 2 {
                        DispatchQueue.main.async {
                            self.resignActive.onNext()
                        }
                    }
                    return true
                }
            }
        }

        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
