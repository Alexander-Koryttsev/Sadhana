//: Playground - noun: a place where people can play

import UIKit
import Foundation

import PlaygroundSupport





class ContentView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var colors = [UIColor.black, UIColor.white]
    var locations = [0.25, 0.75] as [CGFloat]
    var startPoint = CGPoint(x: 0, y: 0.5)
    var endPoint = CGPoint(x: 1, y: 0.5)

    override func draw(_ rect: CGRect) {
        // Setup view
        let colorsInternal = colors.map({ (color) in
            return color.cgColor
        }) as CFArray

        // Prepare a context and create a color space
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()

        // Create gradient object from our color space, color components and locations
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colorsInternal, locations: nil)

        // Draw a gradient
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        context?.restoreGState()
    }
}

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

PlaygroundPage.current.liveView = containerView
