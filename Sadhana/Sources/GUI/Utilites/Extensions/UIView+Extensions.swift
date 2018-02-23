//
//  UIView+Extensions.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-15.0, 15.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        self.layer.add(animation, forKey: "shake")
    }
}
