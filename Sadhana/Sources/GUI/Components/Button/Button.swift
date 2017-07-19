//
//  Button.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class Button: UIButton {
    dynamic override var isEnabled: Bool { get {
            return super.isEnabled
        } set {
            super.isEnabled = newValue
            self.updateBackgroundColor()
        }
    }

    dynamic override var isHighlighted: Bool { get {
        return super.isHighlighted
        } set {
            super.isHighlighted = newValue
            self.updateBackgroundColor()
        }
    }
/*
    override var isSelected: Bool // default is NO may be used by some subclasses or by application

    override var isHighlighted: Bool // default is NO. this gets set/cleared automatically when touch enters/exits during tracking and cleared on up
*/

    init() {
        super.init(frame:CGRect())
    }

    func updateBackgroundColor() {
        if state.contains(.disabled) {
            backgroundColor = UIColor.sdSilver
        }
        else if state.contains(.highlighted) {
            backgroundColor = UIColor.sdBrightBlue
        }
        else {
            backgroundColor = UIColor.sdTangerine
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
