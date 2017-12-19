//
//  JapaView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class JapaView: UIView {

    private let height : CGFloat = 10

    private var entries = [JapaEntry]()
    private var maxCount : Int16 = 16

    struct JapaEntry {
        let rounds : Int16
        let color : UIColor

        init(_ rounds : Int16, _ color : UIColor) {
            self.rounds = rounds
            self.color = color
        }
    }

    init() {
        super.init(frame: CGRect())
        backgroundColor = UIColor.white
    }

    func map(_ entry: Entry, maxCount : Int16? = 16) {
        entries.removeAll()
        if entry.japaCount7_30 > 0 {
            entries.append(JapaEntry(entry.japaCount7_30, UIColor.sdSunflowerYellow))
        }
        if entry.japaCount10 > 0 {
            entries.append(JapaEntry(entry.japaCount10, UIColor.sdTangerine))
        }
        if entry.japaCount18 > 0 {
            entries.append(JapaEntry(entry.japaCount18, UIColor.sdNeonRed))
        }
        if entry.japaCount24 > 0 {
            entries.append(JapaEntry(entry.japaCount24, UIColor.sdBrightBlue))
        }

        self.maxCount = maxCount!
        setNeedsDisplay()

    }

    func clear() {
        entries.removeAll()
        maxCount = 16
        self.setNeedsDisplay()
    }

    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: UIViewNoIntrinsicMetric, height: 22)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        // Prepare a context and create a color space
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()

        // Clip corner radius
        let clipRect = CGRect(x: 0, y: (rect.size.height - height)/2, width: rect.size.width, height: height)
        let clipPath = UIBezierPath(roundedRect: clipRect, cornerRadius: height/2)
        context.addPath(clipPath.cgPath)
        context.clip()
        context.setFillColor(UIColor.sdPaleGrey.cgColor)
        context.fill(rect)

        // Draw
        var lastX : CGFloat = 0
        let roundWidth = rect.width / CGFloat(maxCount)

        var index = 0
        for entry in entries {
            let width = roundWidth * CGFloat(entry.rounds)
            let rectInternal = CGRect(x: lastX, y: clipRect.origin.y, width: width, height: height)
            context.setFillColor(entry.color.cgColor)
            context.fill(rectInternal)
            lastX = lastX + width
            index = index + 1
        }

        context.restoreGState()
        context.saveGState()

        if maxCount > 16 {
            let x = roundWidth * 16
            context.setLineWidth(1)
            context.setStrokeColor(UIColor.sdSilver.cgColor)
            context.addLines(between: [CGPoint(x:x, y:0), CGPoint(x:x, y: clipRect.origin.y - 1)])
            context.addLines(between: [CGPoint(x:x, y:rect.height), CGPoint(x:x, y: clipRect.origin.y + clipRect.height + 1)])
            context.strokePath()
        }
        context.restoreGState()

    }
}
