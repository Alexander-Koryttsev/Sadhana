//
//  BoolFormCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/24/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BoolFormCell: FormCell {
    private let viewModel: VariableFieldVM<Bool>
    private let switcher = UISwitch()
    let disposeBag = DisposeBag()

    init(_ viewModel: VariableFieldVM<Bool>) {
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: nil)
        accessoryView = switcher
        textLabel?.text = viewModel.key.localized
        textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        switcher.isOn = viewModel.variable.value
        switcher.rx.isOn.asDriver().skip(1).drive(viewModel.variable).disposed(by: disposeBag)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

