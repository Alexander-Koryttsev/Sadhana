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
    private let viewModel: VariableFieldVM
    private let switcher = UISwitch()

    init(_ viewModel: VariableFieldVM) {
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: nil)
        accessoryView = switcher
        textLabel?.text = viewModel.key.localized
        textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        switcher.isOn = viewModel.variable.value as! Bool
        switcher.rx.isOn.asDriver().map { (flag) -> Any? in return flag }.drive(viewModel.variable).disposed(by: viewModel.disposeBag)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
