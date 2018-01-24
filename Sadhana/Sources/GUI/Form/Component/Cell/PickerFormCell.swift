//
//  PickerCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/5/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy
import RxCocoa

class PickerFormCell: ResponsibleFormCell, Validable {
    let viewModel : PickerFieldVM
    let valueLabel = UILabel()
    let beginValidation = PublishSubject<Void>()
    var validationAdded = false

    init(_ viewModel: PickerFieldVM) {
        self.viewModel = viewModel
        super.init(style: .value1, reuseIdentifier: nil)

        textLabel?.text = viewModel.key.localized
        textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
        
        valueLabel.textColor = .sdSteel
        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        valueLabel.textAlignment = .right
        viewModel.variable.asDriver().map({ (titled) -> String in
            return titled?.title ?? ""
        }).drive(valueLabel.rx.text).disposed(by: disposeBag)
        contentView.addSubview(valueLabel)
        valueLabel.easy.layout([CenterY(-1), Right()])

        viewModel.variable.asDriver()
            .skip(1)
            .filter { $0 != nil }
            .map { _ -> Void in }
            .drive(goNext).disposed(by: disposeBag)

        accessoryType = .disclosureIndicator

        if let action = viewModel.action {
            becomeActive.subscribe(onNext: { [unowned self] in
                if action() {
                    self.setSelected(true, animated: true)
                }
            }).disposed(by: disposeBag)
        }
        
        if let validDriver = viewModel.valid {
            var beginValidation = self.beginValidation.asDriver(onErrorJustReturn:())
            if let viewModelBeginValidation = viewModel.beginValidation {
                beginValidation = Driver.merge(beginValidation, viewModelBeginValidation)
            }
            
            Driver.combineLatest(beginValidation, validDriver, resultSelector: { [unowned self] (_, valid) -> Void in
                self.set(valid:valid)
            }).drive().disposed(by: disposeBag)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if isSelected, !selected, !validationAdded, viewModel.valid != nil {
            beginValidation.onNext(())
            validationAdded = true
        }
        super.setSelected(selected, animated: animated)
    }
}
