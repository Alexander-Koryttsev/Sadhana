//
//  RootRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class RootRouter {
    
    let window: UIWindow
    
    init(_ aWindow:UIWindow) {
        window = aWindow
    }
    
    func showInitialVC() -> Void {
       /* if let userID = Local.defaults.userID,
            Local.service.viewContext.fetchUser(ID: userID) != nil {
            showTabBarVC()
        } else {*/
            showLoginVC()
        //}
    }
    
    func commitSignIn() -> Void {
        print("signed in!")
    }
    
    private func showLoginVC() -> Void {
        for view in window.subviews {
            view.removeFromSuperview()
        }
        window.rootViewController = LoginVC(viewModel:LoginVM(router: self))
        window.makeKeyAndVisible()
    }
    
    private func showTabBarVC() -> Void {
        for view in window.subviews {
            view.removeFromSuperview()
        }
        window.rootViewController = MainTabBarVC()
        window.makeKeyAndVisible()
    }
    
}
