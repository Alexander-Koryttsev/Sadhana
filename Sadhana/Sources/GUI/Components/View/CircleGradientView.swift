//
//  GradientView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/16/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit


class CircleGradientView: UIView {

    var centerColor = UIColor.sdButterscotch
    var cornerColor = UIColor.sdDarkTaupe

    override func draw(_ rect: CGRect) {
        // Setup view
        let colors = [centerColor.cgColor, cornerColor.cgColor] as CFArray
        let locations = [ 0.0, 1.0 ] as [CGFloat]
        let radius = max(self.bounds.size.height, self.bounds.size.width) / 2
        let center = CGPoint.init(x: bounds.size.width / 2, y: bounds.size.height / 2)

        // Prepare a context and create a color space
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()

        // Create gradient object from our color space, color components and locations
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)

        // Draw a gradient
        context!.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: .drawsAfterEndLocation)
        context?.restoreGState()
    }
}
