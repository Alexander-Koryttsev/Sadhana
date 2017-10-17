//
//  RootRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift
import DynamicButton
import EasyPeasy
import Crashlytics

class RootRouter : WindowRouter {

    static var shared:RootRouter?
    
    let window: UIWindow
    var mainTabBarRouter : MainTabBarRouter

    init(_ aWindow:UIWindow) {
        window = aWindow
        mainTabBarRouter = MainTabBarRouter(window: window)
        RootRouter.shared = self
    }
    
    func showInitialVC() -> Void {
        if let userID = Local.defaults.userID,
            Local.service.viewContext.fetch(userFor: userID) != nil {
            showTabBarVC()
        } else {
            showLoginVC()
        }
    }
    
    func commitSignIn() -> Void {
        self.showTabBarVC()
    }

    func logOut(error: Error? = nil) {
        //TODO: show progress
        self.showLoginVC(error: error)

        Local.defaults.reset()
        Local.service.dropDatabase {}
    }

    func setPlusButton(hidden:Bool, animated:Bool) {
        let animations = { [unowned self] () in
            self.mainTabBarRouter.plusButton.alpha = hidden ? 0 : 1
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: animations)
        }
        else {
            animations()
        }
    }
    
    private func showLoginVC(error: Error? = nil) -> Void {
        mainTabBarRouter.reset()
        let vm = LoginVM()
        setRootViewController(LoginVC(vm))
        if let error = error {
            vm.errors.onNext(error)
        }
    }

    private func showTabBarVC() -> Void {
        mainTabBarRouter.showInitialVC()
    }
}

protocol WindowRouter {
    var window: UIWindow { get }
}

extension WindowRouter {
    func setRootViewController(_ vc: UIViewController) {
        for view in window.subviews {
            view.removeFromSuperview()
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
