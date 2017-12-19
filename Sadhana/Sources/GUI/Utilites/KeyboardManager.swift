//
//  KeyboardManager.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy
import AudioToolbox
import RxCocoa
import RxSwift
import Crashlytics

class KeyboardManager {
    static let shared = KeyboardManager()
    var showBackNextButtons = false
    var isKeyboardShown : Bool {
        get {
            return keyboardShown
        }
    }
    let backButton : Button
    let nextButton : Button

    private let keyboardContainer = KeyboardContainer()
    private var keyboardShown = false

    init() {
        backButton = keyboardContainer.backButton
        nextButton = keyboardContainer.nextButton

        _ = backButton.rx.tap.asDriver().drive(onNext:{
            AudioServicesPlaySystemSound(1155)
            Answers.logCustomEvent(withName: "Keyboard Back", customAttributes: nil)
        })

        _ = nextButton.rx.tap.asDriver().drive(onNext:{
            AudioServicesPlaySystemSound(1123)
            Answers.logCustomEvent(withName: "Keyboard Next", customAttributes: nil)
        })

        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardDidHide(_:)), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillChange(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidShow(_ notification : Notification) {
        keyboardShown = true
    }

    @objc func keyboardDidHide(_ notification : Notification) {
        keyboardShown = false
        showBackNextButtons = false
    }

    @objc func keyboardWillChange(_ notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            var beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
            var endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        if iPhoneX {
            beginFrame.size.height = beginFrame.height - 75
            endFrame.size.height = endFrame.height - 75
        }

        keyboardContainer.isHidden = !showBackNextButtons

        if showBackNextButtons {
            let keyBoardWindow = UIApplication.shared.windows.last
            keyBoardWindow?.addSubview(keyboardContainer)
            keyBoardWindow?.bringSubview(toFront: keyboardContainer)
            UIView.setAnimationsEnabled(false)
            keyboardContainer.frame = beginFrame
            UIView.setAnimationsEnabled(true)

            UIView.animate(withDuration: 0.3) {
                self.keyboardContainer.frame = endFrame
            }
        }
    }
}

class KeyboardContainer : UIView {
    fileprivate let buttonContainer = UIView()
    fileprivate let backButton = Button()
    fileprivate let nextButton = Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        if iOS(11) {
            buttonContainer.layer.masksToBounds = true
            buttonContainer.layer.cornerRadius = 5
        }

        addSubview(buttonContainer)
        buttonContainer.easy.layout([
            Width(==(iOS(11) ? -7 : -1)*0.33).like(self),
            Height(==(iOS(11) ? -7.5 : 0 )*0.25).like(self),
            Left(iOS(11) ? 6 : 0),
            Bottom(iOS(11) ? 3 : 0)
        ])

        buttonContainer.addSubview(backButton)
        let image = UIImage(cgImage: #imageLiteral(resourceName: "login-arrow").cgImage!, scale: UIScreen.main.scale, orientation: .upMirrored)
        backButton.setImage(image, for: UIControlState())
        backButton.adjustsImageWhenHighlighted = false
        backButton.easy.layout([
            Top(),
            Left(),
            Bottom(),
        ])

        buttonContainer.addSubview(nextButton)
        nextButton.setImage(#imageLiteral(resourceName: "login-arrow"), for: UIControlState())
        nextButton.adjustsImageWhenHighlighted = false
        nextButton.easy.layout([
            Top(),
            Right(),
            Bottom(),
            Left().to(backButton),
            Width().like(backButton)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return buttonContainer.frame.contains(point)
    }
}
