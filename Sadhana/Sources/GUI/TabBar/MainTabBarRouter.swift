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

class MainTabBarRouter : SadhanaEditingRouter, WindowRouter {
    var mySadhanaRouter = MySadhanaRouter()
    var tabBarVC : MainTabBarVC?
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
    }

    func showInitialVC() {
        mySadhanaRouter.parent = self
        tabBarVC = MainTabBarVC(MainTabBarVM(self))
        tabBarVC!.setViewControllers([mySadhanaRouter.initialVC()], animated: false)
        setRootViewController(tabBarVC!)
        setUpPlusButton()
    }

    func reset() {
        tabBarVC?.view.removeFromSuperview()
        tabBarVC = nil
        isEditing = false
        plusButton.setStyle(.plus, animated: false)
        plusButton.removeFromSuperview()
    }

    func showSadhanaEditing(date: Date) {
        let vm = SadhanaEditingVM(self)
        plusButton.rx.tap.asDriver().drive(vm.save).disposed(by: vm.disposeBag)
        //TODO: cancel warning
        let vc = SadhanaEditingVC(vm)
        let navVC = NavigationVC(rootViewController: vc)
        tabBarVC?.present(navVC, animated: true, completion: nil)
        isEditing = true
    }

    func hideSadhanaEditing() {
        tabBarVC?.dismiss(animated: true, completion: nil)
        isEditing = false
    }

    @objc private func togglePlusButton(sender:DynamicButton) {
        isEditing ? hideSadhanaEditing() : showSadhanaEditing()
    }

    private func setUpPlusButton() {
        plusButton.strokeColor = .white
        plusButton.backgroundColor = .sdTangerine
        let inset = CGFloat(10)
        let size = CGFloat(40)
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = size/2
        plusButton.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        window.addSubview(plusButton)
        plusButton <- [
            CenterX(),
            Size(size),
            Bottom(5)
        ]
        plusButton.addTarget(self, action:#selector(togglePlusButton(sender:)), for: .touchUpInside)
    }
}

protocol SadhanaEditingRouter {
    func showSadhanaEditing(date: Date)
    func hideSadhanaEditing()
}

extension SadhanaEditingRouter {
    func showSadhanaEditing() {
        showSadhanaEditing(date: Date())
    }
}
