//: Playground - noun: a place where people can play

import UIKit
import Foundation

import PlaygroundSupport

let loc = Locale.current.languageCode!
print("loc : \(loc)")
let pre = Locale.preferredLanguages.first!
/*

class GradientView: UIView {
    override public class var layerClass: Swift.AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    var gradientLayer : CAGradientLayer {
        return layer as! CAGradientLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
containerView.backgroundColor = UIColor.white
let contentView = GradientView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
contentView.backgroundColor = UIColor.clear
contentView.alpha = 0.8
containerView.addSubview(contentView)

PlaygroundPage.current.liveView = containerView*/
