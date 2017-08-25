//
//  MainTabBarRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import DynamicButton
import EasyPeasy
import RxCocoa
import RxSwift

class MainTabBarRouter : EditingRouter, WindowRouter {
    var myGraphRouter = MyGraphRouter()
    let otherGraphListRouter = OtherGraphListRouter()
    weak var tabBarVC : MainTabBarVC?
    let window : UIWindow
    let plusButton = DynamicButton(style: .plus)
    var isEditing = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.plusButton.setStyle(self.isEditing ? .checkMark : .plus, animated: true)
            }
        }
    }

    init(window: UIWindow) {
        self.window = window
        otherGraphListRouter.parent = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange(notification:)), name: .UIKeyboardDidChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        plusButton.removeTarget(nil, action: nil, for: .allEvents)
    }

    @objc func keyboardWillChange(notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboarFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let shown = keyboarFrame.origin.y < UIScreen.main.bounds.size.height

        UIView.animate(withDuration: 0.3) {
            self.plusButton <- Bottom((shown ? keyboarFrame.size.height : 0) + 5)
            self.window.layoutIfNeeded()
        }
    }

    @objc func keyboardDidChange(notification:NSNotification) {

    }

    func showInitialVC() {
        myGraphRouter.parent = self
        let tabBarVC = MainTabBarVC(MainTabBarVM(self))
        tabBarVC.setViewControllers([myGraphRouter.initialVC(), otherGraphListRouter.initialVC], animated: false)
        setRootViewController(tabBarVC)
        setUpPlusButton()
        self.tabBarVC = tabBarVC
    }

    func reset() {
        tabBarVC?.view.removeFromSuperview()
        tabBarVC = nil
        isEditing = false
        plusButton.setStyle(.plus, animated: false)
        plusButton.removeFromSuperview()
    }

    func showSadhanaEditing(date: Date) {
        let vm = EditingVM(self, date:date)
        plusButton.rx.tap.bind(to:vm.save).disposed(by: vm.disposeBag)
        let vc = EditingVC(vm)
        tabBarVC?.present(vc, animated: true, completion: nil)
        isEditing = true
    }

    func hideSadhanaEditing() {
        tabBarVC?.presentedViewController?.setEditing(false, animated: true)
        tabBarVC?.dismiss(animated: true, completion: nil)
        isEditing = false
    }

    @objc private func togglePlusButton(sender:DynamicButton) {
        isEditing ? hideSadhanaEditing() : showSadhanaEditing()
    }

    func showMyGraph() {
        tabBarVC?.selectedIndex = 0
    }

    private func setUpPlusButton() {
        plusButton.strokeColor = .white
        plusButton.backgroundColor = .sdTangerine
        let inset = CGFloat(12)
        let size = CGFloat(40)
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = size/2
        plusButton.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        plusButton.alpha = 1
        window.addSubview(plusButton)
        plusButton <- [
            CenterX(),
            Size(size),
            Bottom(5)
        ]
        plusButton.addTarget(self, action:#selector(togglePlusButton(sender:)), for: .touchUpInside)
    }
}

protocol EditingRouter {
    func showSadhanaEditing(date: Date)
    func hideSadhanaEditing()
}

extension EditingRouter {
    func showSadhanaEditing() {
        showSadhanaEditing(date: Date())
    }
}
