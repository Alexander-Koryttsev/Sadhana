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
        titleLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.regular)
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

        var previousField : FormTextField?
        for view in countViews {
            if let previousField = previousField {

                view.valueField.resignActive.filter({ (isNext) -> Bool in
                    return !isNext
                })
                    .bind(to:previousField.becomeActive).disposed(by: disposeBag)

                previousField.resignActive.filter({ (isNext) -> Bool in
                    return isNext
                })
                    .bind(to:view.valueField.becomeActive).disposed(by: disposeBag)
            }
            
            previousField = view.valueField
        }

        countViews.first!.valueField.resignActive.filter({ (isNext) -> Bool in
            return !isNext
        })  .bind(to:resignActive).disposed(by: disposeBag)

        countViews.last!.valueField.resignActive.filter({ (isNext) -> Bool in
            return isNext
        })  .bind(to:resignActive).disposed(by: disposeBag)

        becomeActive.filter { (isNext) -> Bool in
            return isNext
        }   .bind(to: countViews.first!.valueField.becomeActive).disposed(by: disposeBag)

        becomeActive.filter { (isNext) -> Bool in
            return !isNext
        }   .bind(to: countViews.last!.valueField.becomeActive).disposed(by: disposeBag)
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

  /*  override func becomeFirstResponder() -> Bool {
        for view in countViews {
            if (view.valueField.text == nil || view.valueField.text!.isEmpty) {
                return view.valueField.becomeFirstResponder()
            }
        }
        return false
    }
*/
    override func height() -> CGFloat {
        return 100
    }
}

class CountContainerCell: CountsLayoutCell, UITextFieldDelegate {
    private let viewModel: FieldsContainer<Int16>

    init(_ viewModel: FieldsContainer<Int16>) {
        self.viewModel = viewModel
        super.init(fieldsCount:viewModel.fields.count)

        set(colors: viewModel.colors)
        titleLabel.text = viewModel.key.localized
        for (vm, view) in zip(viewModel.fields, countViews) {
            view.titleLabel.text = vm.key.localized
            view.valueField.delegate = self
            let value = vm.variable.value
            if value > 0 {
                view.valueField.text = value.description
            }
            view.valueField.rx.textRequired.asDriver().skip(1).map({ (string) -> Int16 in
                return Int16(string) ?? 0
            }).drive(vm.variable).disposed(by: disposeBag)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textField = textField as! FormTextField
        let nsString = textField.text as NSString?
        if let resultString = nsString?.replacingCharacters(in: range, with: string) {
            if resultString.isEmpty {
                return true
            }

            if Int16(resultString) != nil {
                if resultString.characters.count > 1 {
                    DispatchQueue.main.async {
                        textField.resignActive.onNext(true)
                    }
                }
                return true
            }
        }
        return false
    }
}
