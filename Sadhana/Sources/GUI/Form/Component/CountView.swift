//
//  CountView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/23/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy

class CountView: UIView, ResponsibleContainer {
    let valueField = NumberField()
    var responsible: Responsible {
        return valueField
    }
    let titleLabel = UILabel()

    init() {
        super.init(frame: CGRect())

        backgroundColor = .white

        addSubview(valueField)
        valueField.font = .sdTextStyle1_1Font
        valueField.textAlignment = .center
        valueField.keyboardType = .asciiCapableNumberPad
        valueField.placeholder = "0"
        valueField.easy.layout([
            Top(-8),
            CenterX(),
            Width(60),
            Height(44),
            
        ])

        addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.regular)
        titleLabel.textColor = .sdSilver
        titleLabel.easy.layout([
            CenterX().to(valueField),
            Top(-5).to(valueField),
            Bottom(>=0)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
