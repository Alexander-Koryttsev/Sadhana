//
//  GuideView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 12/15/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class GuideView: UIView {

    let backgroundView = CircleGradientView()
    weak var closeButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame:frame)

        backgroundView.alpha = 0.7
        backgroundView.colors = [.clear, .black]
        backgroundView.backgroundColor = .clear

        addSubview(backgroundView)

        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func highlight(_ view: UIView) {
        backgroundView.gradientCenter = backgroundView.convert(view.center, from: view.superview)
        backgroundView.startRadius = max(view.bounds.size.width, view.bounds.size.height)
        backgroundView.endRadius = backgroundView.startRadius + 16
        backgroundView.setNeedsDisplay()
    }

    func createLabel(_ key: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = key.localized
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        addSubview(label)
        return label
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
    }

    deinit {
        closeButton?.removeFromSuperview()
    }
}

