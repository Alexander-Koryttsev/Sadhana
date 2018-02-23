//
//  GradientView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/16/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//




class RadialGradientView: UIView {
    var colors = [UIColor.sdButterscotch, UIColor.sdDarkTaupe]
    var locations = [0.0, 1.0] as [CGFloat]
    var startRadius = CGFloat(0)
    var endRadius : CGFloat?
    var gradientCenter : CGPoint?

    override func draw(_ rect: CGRect) {
        // Setup view
        let colorsInternal = colors.map({ (color) in
            return color.cgColor
        }) as CFArray
        let endRadiusInternal = endRadius ?? max(self.bounds.size.height, self.bounds.size.width) / 2
        let centerInternal = gradientCenter ?? CGPoint.init(x: bounds.size.width / 2, y: bounds.size.height / 2)

        // Prepare a context and create a color space
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()

        // Create gradient object from our color space, color components and locations
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colorsInternal, locations: locations)
        
        // Draw a gradient
        context!.drawRadialGradient(gradient!, startCenter: centerInternal, startRadius: startRadius, endCenter: centerInternal, endRadius: endRadiusInternal, options: .drawsAfterEndLocation)
        context?.restoreGState()
    }
}

class LinearGradientView: UIView {
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

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(white:0, alpha:0.4).cgColor]
        gradientLayer.locations = [0.0, 1.0]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
