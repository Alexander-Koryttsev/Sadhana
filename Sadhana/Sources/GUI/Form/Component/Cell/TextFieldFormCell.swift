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


class TextFieldFormCell: FormCell, ResponsibleContainer {

    let type : TextFieldType
    let titleLabel = UILabel()
    let textField = TextField()
    var responsible: Responsible {
        return textField
    }

    var validDriver : Driver<Bool>?

    let viewModel : VariableFieldVM<String>
    let disposeBag = DisposeBag()

    init(_ viewModel: VariableFieldVM<String>) {
        self.viewModel = viewModel

        switch viewModel.type {
            case .text(let fieldType):
                type = fieldType
                switch fieldType {
                    case .name:
                        textField.autocapitalizationType = .words
                        break
                    case .email:
                        textField.keyboardType = .emailAddress
                        break
                    case .password:
                        textField.isSecureTextEntry = true
                        break
                    default: break
                }
            default:
                fatalError("Can't create TextFieldFormCell with\(viewModel.type), only FormFieldType.text allowed")
                break
        }

        super.init(style: .default, reuseIdentifier: TextFieldFormCell.classString)

        titleLabel.text = viewModel.key.localized
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
        contentView.addSubview(titleLabel)
        titleLabel.easy.layout([
            Left(15),
            CenterY()
        ])

        textField.text = viewModel.variable.value

        if let validDriver = viewModel.valid {
            Driver.combineLatest(textField.rx.controlEvent(.editingDidEnd).take(1).asDriver(onErrorJustReturn: ()), validDriver, resultSelector: { [unowned self] (_, valid) -> Void in
                self.set(valid:valid)
            }).drive().disposed(by: disposeBag)
        }

        textField.rx.textRequired.asDriver().drive(viewModel.variable).disposed(by: disposeBag)
        textField.returnKeyType = .next
        textField.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        contentView.addSubview(textField)
        textField.easy.layout([
            Left(10).to(titleLabel, .right),
            Top(),
            Height(height).with(.medium),
            Bottom(),
            Width(*0.5).like(contentView),
            Right(16)
        ])

        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            becomeActive.onNext(())
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

}
