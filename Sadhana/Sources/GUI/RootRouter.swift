//
//  RootRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift

class RootRouter {

    static var shared:RootRouter?
    
    let window: UIWindow
    let mainTabBarRouter = MainTabBarRouter()
    
    init(_ aWindow:UIWindow) {
        window = aWindow
        RootRouter.shared = self
    }
    
    func showInitialVC() -> Void {
        if let userID = Local.defaults.userID,
            Local.service.viewContext.fetchUser(ID: userID) != nil {
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
        for view in window.subviews {
            view.removeFromSuperview()
        }
        let vm = LoginVM(self)
        window.rootViewController = LoginVC(vm)
        window.makeKeyAndVisible()

        if let errorMessage = errorMessage {
            vm.errorMessages.onNext(errorMessage)
        }
    }

    private func showTabBarVC() -> Void {
        for view in window.subviews {
            view.removeFromSuperview()
        }
        window.rootViewController = mainTabBarRouter.initialVC()
        window.makeKeyAndVisible()
    }
}
