//
//  ContainerCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/23/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

import RxCocoa
import EasyPeasy

class CountsLayoutCell: FormCell, ResponsibleChain {
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let countViewsBackgroundView = UIView()
    let disposeBag = DisposeBag()
    var countViews : [CountView] {
        get {
            return stackView.arrangedSubviews as! [CountView]
        }
    }
    var responsibles: [Responsible] {
        return countViews
    }
    
    var becomeActive : PublishSubject<Void> {
        for item in countViews {
            if item.valueField.text == nil || item.valueField.text!.count == 0 {
                return item.becomeActive
            }
        }
        
        return responsibles.first!.becomeActive
    }

    init(fieldsCount:Int) {
        super.init(style: .default, reuseIdentifier: nil)

        selectionStyle = .none
        separatorInset = UIEdgeInsets()

        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.regular)
        titleLabel.easy.layout([
            CenterX(),
            Top(9),
            Height(18)
        ])

        contentView.addSubview(countViewsBackgroundView)
        countViewsBackgroundView.backgroundColor = .sdSilver
        countViewsBackgroundView.easy.layout([
            Top(10).to(titleLabel),
            Left(4),
            Right(4),
            Bottom(14)
        ])

        countViewsBackgroundView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        stackView.easy.layout(Edges())

        for _ in (0..<fieldsCount) {
            stackView.addArrangedSubview(CountView())
        }

        var previousView : CountView?
        for view in countViews {
            if let previousView = previousView {
                view.goBack.bind(to:previousView.becomeActive).disposed(by: disposeBag)
                previousView.goNext.bind(to:view.becomeActive).disposed(by: disposeBag)
            }
            
            previousView = view
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

    override var height : CGFloat {
        return 100
    }
}

class CountContainerCell: CountsLayoutCell, UITextFieldDelegate {
    private let viewModel: FieldsContainerVM
    
    override var isFilled : Bool {
        return viewModel.isFilled
    }

    init(_ viewModel: FieldsContainerVM) {
        self.viewModel = viewModel
        super.init(fieldsCount:viewModel.fields.count)

        set(colors: viewModel.colors)
        titleLabel.text = viewModel.key.localized
        for (vm, view) in zip(viewModel.fields, countViews) {
            view.titleLabel.text = vm.key.localized
            view.valueField.delegate = self
            if let variableField = vm as? VariableFieldVM<Int16> {
                let value = variableField.variable.value
                if value > 0 {
                    view.valueField.text = value.description
                }
                view.valueField.rx.textRequired.asDriver().skip(2).map({ (string) -> Int16 in
                    return Int16(string) ?? 0
                }).drive(variableField.variable).disposed(by: disposeBag)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textField = textField as! NumberField
        let nsString = textField.text as NSString?
        if let resultString = nsString?.replacingCharacters(in: range, with: string) {
            if resultString.isEmpty {
                return true
            }

            if Int16(resultString) != nil {
                if resultString.count > 1 {
                    DispatchQueue.main.async {
                        textField.goNext.onNext(())
                    }
                }
                return true
            }
        }
        return false
    }
}
