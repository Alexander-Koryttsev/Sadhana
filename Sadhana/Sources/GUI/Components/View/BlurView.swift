//
//  BlurView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/19/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy


class BlurView : UIVisualEffectView {
    
    var showTopSeparator : Bool {
        get {
            return !topSeparator.isHidden
        }
        set {
            topSeparator.isHidden = !newValue
        }
    }
    var showBottomSeparator : Bool {
        get {
            return !bottomSeparator.isHidden
        }
        set {
            bottomSeparator.isHidden = !newValue
        }
    }
    private let topSeparator = UIView()
    private let bottomSeparator = UIView()
    
    init() {
        super.init(effect: UIBlurEffect(style: .prominent))
        let separatorColor = UIColor(white: 0.6814, alpha: 1)
        topSeparator.backgroundColor = separatorColor
        topSeparator.isHidden = true
        contentView.addSubview(topSeparator)
        topSeparator.easy.layout([
            Left(),
            Right(),
            Top(),
            Height(0.25)
            ])
        bottomSeparator.backgroundColor = separatorColor
        contentView.addSubview(bottomSeparator)
        bottomSeparator.easy.layout([
            Left(),
            Right(),
            Bottom(),
            Height(0.5)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
