//
//  TextFieldFormCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 11/18/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy
import RxCocoa
import RxSwift

class TextFieldFormCell: FormCell {

    let titleLabel = UILabel()
    let textField = UITextField()

    let viewModel : VariableFieldVM<String>
    let disposeBag = DisposeBag()

    init(_ viewModel: VariableFieldVM<String>) {
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: TextFieldFormCell.classString)

        titleLabel.text = viewModel.key.localized
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        contentView.addSubview(titleLabel)
        titleLabel.easy.layout([
            Left(10),
            CenterY()
        ])

        textField.text = viewModel.variable.value
        textField.rx.textRequired.asDriver().drive(viewModel.variable).disposed(by: disposeBag)
        contentView.addSubview(textField)
        textField.easy.layout([
            Left(10).to(titleLabel, .right),
            CenterY(),
            Right(10)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
