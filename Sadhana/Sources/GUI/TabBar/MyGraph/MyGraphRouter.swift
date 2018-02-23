//
//  MyGraphRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import MessageUI
import DynamicButton

class MyGraphRouter : EditingRouter {
    weak var parent : MainTabBarRouter?
    let navVC = NavigationVC()
    let composerDelegate = ComposerDelegate()
    var plusButton: DynamicButton {
        return parent!.plusButton
    }

    var initialVC : UIViewController {
        navVC.viewControllers = [ MyGraphVC(MyGraphVM(self)) ]
        navVC.view.backgroundColor = .white
        return navVC
    }

    func showSadhanaEditing(date: Date) {
        self.parent?.showSadhanaEditing(date: date)
    }

    func hideSadhanaEditing() {
        self.parent?.hideSadhanaEditing()
    }
    
    func showSettings() {
        navVC.pushViewController(SettingsVC(SettingsVM(self)), animated: true)
    }

    func show(mailComposer: MFMailComposeViewController) {
        mailComposer.navigationBar.tintColor = AppDelegate.shared.window?.tintColor
        mailComposer.mailComposeDelegate = composerDelegate
        navVC.present(mailComposer, animated: true, completion: nil)
    }
}

class ComposerDelegate : NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

