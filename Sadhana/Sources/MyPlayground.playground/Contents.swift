//: Playground - noun: a place where people can play

import UIKit
import Foundation

import PlaygroundSupport



let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
containerView.backgroundColor = UIColor.white
let contentView = ContentView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
contentView.backgroundColor = UIColor.clear
contentView.alpha = 0.8
containerView.addSubview(contentView)


class ContentView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var colors = [UIColor.clear, UIColor(white: 0.5, alpha: 1)]
    var locations = [0.5, 1.0] as [CGFloat]

    override func draw(_ rect: CGRect) {
        // Setup view
        let colorsInternal = colors.map({ (color) in
            return color.cgColor
        }) as CFArray
        let radius = CGFloat(100)
        let center = CGPoint(x: 100, y: bounds.size.height / 2)

        // Prepare a context and create a color space
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()

        // Create gradient object from our color space, color components and locations
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colorsInternal, locations: locations)

        // Draw a gradient
        context!.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: .drawsAfterEndLocation)
        context?.restoreGState()
    }
}

PlaygroundPage.current.liveView = containerView

