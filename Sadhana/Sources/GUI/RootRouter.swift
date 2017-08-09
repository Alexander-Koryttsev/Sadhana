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
        showTabBarVC()
    }

    func logOut(errorMessage: String? = nil) {
        //TODO: show progress
        showLoginVC(errorMessage: errorMessage)
        Local.defaults.reset()
        Local.service.dropDatabase {}
    }
    
    private func showLoginVC(errorMessage: String? = nil) -> Void {
        mainTabBarRouter.reset()
        let vm = LoginVM()
        setRootViewController(LoginVC(vm))
        if let errorMessage = errorMessage {
            vm.handle(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
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
