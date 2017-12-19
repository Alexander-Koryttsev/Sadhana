//
//  CircleView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/25/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class CircleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.setFillColor(tintColor.cgColor)
        context.fillEllipse(in: rect)
        context.restoreGState()
    }
}
