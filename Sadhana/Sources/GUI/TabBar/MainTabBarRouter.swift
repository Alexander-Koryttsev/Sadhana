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
    var isEditing = false

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
        let vc = SadhanaEditingVC(SadhanaEditingVM(self))
        let navVC = NavigationVC(rootViewController: vc)
        tabBarVC?.present(navVC, animated: true, completion: nil)
    }

    func hideSadhanaEditing() {
        tabBarVC?.dismiss(animated: true, completion: nil)
    }

    @objc func togglePlusButton(sender:DynamicButton) {
        isEditing = !isEditing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.plusButton.setStyle(self.isEditing ? .checkMark : .plus, animated: true)
        }

        if (isEditing) {
            showSadhanaEditing()
        }
        else {
            hideSadhanaEditing()
        }
    }

    private func setUpPlusButton() {
        //TODO: animation
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
