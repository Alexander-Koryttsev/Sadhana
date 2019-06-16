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

    func showSadhanaEditing(date: LocalDate) {
        self.parent?.showSadhanaEditing(date: date)
    }

    func hideSadhanaEditing() {
        self.parent?.hideSadhanaEditing()
    }
    
    func showSettings() {
        navVC.pushViewController(RootSettingsVC(RootSettingsVM(self)), animated: true)
    }

    func showGraphEditingSettings() {
        navVC.pushViewController(BaseSettingsVC(GraphEditingSettingsVM(self)), animated: true)
    }

    func showProfileSettings() {
        navVC.pushViewController(BaseSettingsVC(ProfileEditingSettingsVM(self)), animated: true)
    }

    func showCSVExport() {
        let vc = CSVExporterVC(CSVExporterVM(self))
        present(vc)
    }

    func doneCSVExport(with urls: [URL]) {
        navVC.dismiss(animated: true) {
            let vc = UIActivityViewController(activityItems: urls, applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.postToTwitter,
                UIActivityType.postToFacebook
            ]
            vc.completionWithItemsHandler = {(type, completed, _, error) -> Void in
                log("Share CSV Completion:\ntype: \(String(describing: type))\ncompleted: \(completed)\nerror: \(String(describing: error))")
            }
            self.present(vc)
        }
    }

    func hideCSVExport() {
        navVC.dismiss(animated: true, completion: nil)
    }

    func show(mailComposer: MFMailComposeViewController) {
        mailComposer.navigationBar.tintColor = AppDelegate.shared.window?.tintColor
        mailComposer.mailComposeDelegate = composerDelegate
        navVC.present(mailComposer, animated: true, completion: nil)
    }

    func present(_ viewController: UIViewController) {
        navVC.present(viewController, animated: true, completion: nil)
    }
}

class ComposerDelegate : NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

