//
//  RootRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

import DynamicButton
import EasyPeasy
import Crashlytics

class RootRouter : WindowRouter {

    static var shared:RootRouter?
    
    let window: UIWindow
    var mainTabBarRouter: MainTabBarRouter?
    
    init(_ aWindow:UIWindow) {
        window = aWindow
        RootRouter.shared = self
    }
    
    func showInitialVC() -> Void {
        if let userID = Local.defaults.userID,
            Local.service.viewContext.fetchUser(for: userID) != nil {
            showTabBarVC()
        } else {
            showLoginVC()
        }
    }
    
    func commitSignIn() -> Void {
        self.showTabBarVC()
    }

    func logOut(error: Error? = nil) {
        mainTabBarRouter = nil
        //TODO: show progress
        self.showLoginVC(error: error)

        Local.defaults.reset()
        Local.service.dropDatabase {}
    }

    func setPlusButton(hidden:Bool, animated:Bool) {
        if let tabBarRouter = mainTabBarRouter {
            let animations = {
                tabBarRouter.plusButton.alpha = hidden ? 0 : 1
            }

            if animated {
                UIView.animate(withDuration: 0.25, animations: animations)
            }
            else {
                animations()
            }
        }
    }
    
    private func showLoginVC(error: Error? = nil) {
        let vm = LoginVM()
        setRootViewController(LoginVC(vm))
        if let error = error {
            vm.errors.onNext(error)
        }
    }

    private func showTabBarVC() -> Void {
        mainTabBarRouter = MainTabBarRouter(window: window)
        mainTabBarRouter!.showInitialVC()
    }

    func showRegistration() {
        let regVC = RegistrationVC(RegistrationVM())
        regVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(hideRegistration))
        let navVC = NavigationVC(rootViewController: regVC)
        window.rootViewController?.present(navVC, animated: true, completion: nil)
    }

    @objc func hideRegistration() {
        window.rootViewController?.dismiss(animated: true)
    }

    func show(picker: FormPickerVM) {
        let pickerVC = FormPickerVC(picker)
        if let navVC = window.rootViewController?.presentedViewController as? NavigationVC {
            navVC.pushViewController(pickerVC, animated: true)
        }
    }

    func hidePicker() {
        if let navVC = window.rootViewController?.presentedViewController as? NavigationVC {
            navVC.popToRootViewController(animated: true)
        }
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
