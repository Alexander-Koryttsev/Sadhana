//
//  BoolFormCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/24/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


class BoolFormCell: FormCell {
    private let viewModel: DataFormFieldVM<Bool>
    private let switcher = UISwitch()
    let disposeBag = DisposeBag()

    init(_ viewModel: DataFormFieldVM<Bool>) {
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: nil)
        accessoryView = switcher
        textLabel?.text = viewModel.title
        textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        selectionStyle = .none
        reloadData()

        switcher.rx.isOn.distinctUntilChanged().skip(1).bind(to:viewModel.variable).disposed(by: disposeBag)
        switcher.isEnabled = viewModel.enabled
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        switcher.isOn = viewModel.variable.value
    }
}

