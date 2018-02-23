//
//  File.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 11/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import DynamicButton
import EasyPeasy

class UIFactory {
    class var editingButton : DynamicButton {
        let plusButton = DynamicButton(style: .plus)
        plusButton.strokeColor = .white
        plusButton.backgroundColor = .sdTangerine
        let inset = CGFloat(12)
        let size = CGFloat(40)
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = size/2
        plusButton.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        plusButton.alpha = 1
        plusButton.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        return plusButton
    }
}
