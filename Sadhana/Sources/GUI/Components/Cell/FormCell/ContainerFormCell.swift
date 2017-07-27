//
//  ContainerCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/23/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EasyPeasy

class CountsLayoutCell: ResponsibleCell {
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let countViewsBackgroundView = UIView()
    var countViews : [CountView] {
        get {
            return stackView.arrangedSubviews as! [CountView]
        }
    }

    init(fieldsCount:Int) {
        super.init(style: .default, reuseIdentifier: nil)

        selectionStyle = .none
        separatorInset = UIEdgeInsets()

        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular)
        titleLabel <- [
            CenterX(),
            Top(9),
            Height(18)
        ]

        contentView.addSubview(countViewsBackgroundView)
        countViewsBackgroundView.backgroundColor = .sdSilver
        countViewsBackgroundView <- [
            Top(10).to(titleLabel),
            Left(4),
            Right(4),
            Bottom(14)
        ]

        countViewsBackgroundView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        stackView <- Edges()

        for _ in (0..<fieldsCount) {
            stackView.addArrangedSubview(CountView())
        }
    }

    func set(colors: [UIColor]?) {
        if let colors = colors {
            for (view, color) in zip(countViews, colors) {
                view.valueField.textColor = color
            }
        }
        else {
            countViews.forEach({ (view) in
                view.valueField.textColor = nil
            })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        for view in countViews {
            if (view.valueField.text == nil || view.valueField.text!.isEmpty) {
                return view.valueField.becomeFirstResponder()
            }
        }
        return false
    }

    override func height() -> CGFloat {
        return 100
    }
}

class CountContainerCell: CountsLayoutCell, UITextFieldDelegate {
    private let viewModel: FieldsContainerVM

    init(_ viewModel: FieldsContainerVM) {
        self.viewModel = viewModel
        super.init(fieldsCount:viewModel.fields.count)

        set(colors: viewModel.colors)
        titleLabel.text = viewModel.key.localized
        var previousField : TextField?
        for (vm, view) in zip(viewModel.fields, countViews) {
            view.titleLabel.text = vm.key.localized
            view.valueField.delegate = self

            if let value = vm.variable.value as? Int16 {
                if value > 0 {
                    view.valueField.text = value.description
                }
                view.valueField.rx.textRequired.asDriver().skip(1).map({ (string) -> Int16 in
                    return Int16(string) ?? 0
                }).drive(vm.variable).disposed(by: disposeBag)
            }

            if let previousField = previousField {
                view.valueField.deleteWhenEmpty.drive(onNext: {
                    previousField.becomeFirstResponder()
                }).disposed(by: disposeBag)
                //TODO: set up next responder
            }

            previousField = view.valueField
        }

        countViews.first!.valueField.deleteWhenEmpty.drive(goBack).disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        if let resultString = nsString?.replacingCharacters(in: range, with: string) {
            if resultString.isEmpty {
                return true
            }

            if Int16(resultString) != nil {
                if resultString.characters.count > 1 {
                    DispatchQueue.main.async {
                        var isNext = false
                        var nextField : TextField?
                        for view in self.countViews {
                            if isNext {
                                nextField = view.valueField
                                break
                            }
                            if view.valueField == textField {
                                isNext = true
                            }
                        }
                        if let nextField = nextField {
                            nextField.becomeFirstResponder()
                        }
                        else {
                            self.resignActive.onNext()
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}
