//
//  SettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import MessageUI

class SettingsVM : BaseVM {

    unowned let router : MyGraphRouter
    var sections = [SettingsSection]()

    init(_ router: MyGraphRouter) {
        self.router = router
        super.init()

        addUserInfoItem()
        addFeedbackItem()
        addSignOutItem()
    }

    func addUserInfoItem() {
        if let user = Main.service.user {
            let userInfo = SettingInfo(key: user.name, imageURL: user.avatarURL)
            addSingle(item: userInfo)
        }
    }

    func addFeedbackItem() {
        let action = SettingAction(key: "letterToDevs".localized, destructive: false, action: { [unowned self] in
            let address = "feedback.sadhana@gmail.com"
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.setToRecipients([address])
                mailComposerVC.title = "letterToDevs".localized

                let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

                let deviceData = """
                machine: \(Sysctl.machine)
                model: \(Sysctl.model)
                osVersion: \(Sysctl.osVersion)
                version: \(Sysctl.version)
                appVersion: \(version)(\(buildNumber))
                """

                mailComposerVC.addAttachmentData(deviceData.data(using:.utf8)!, mimeType: "text", fileName: "deviceInfo".localized + ".txt")
                self.router.show(mailComposer: mailComposerVC)
            }
            else {
                let alert = Alert()
                alert.title = "cantSendMailTitle".localized
                alert.message = String(format: "cantSendMailMessage".localized, address)
                alert.add(action: "copyAddres".localized, handler: {
                    UIPasteboard.general.string = address
                })
                alert.addCancelAction()
                self.alerts.onNext(alert)
            }
        })

        addSingle(item: action)
    }

    func addSignOutItem() {
        let logoutAction = SettingAction(key: "signOut".localized, destructive: true) { [unowned self] in
            let alert = Alert()
            alert.add(action:"signOut".localized, style: .destructive, handler: {
                RootRouter.shared?.logOut()
            })

            alert.addCancelAction()
            self.alerts.onNext(alert)
        }
        addSingle(item: logoutAction)
    }

    func addSingle(item: FormField) {
        sections.append(SettingsSection(title: "", items: [item]))
    }
}



struct SettingsSection {
    let title : String
    let items : [FormField]
}

struct SettingAction : FormField {
    let key : String
    let destructive : Bool
    let action : Block
}

struct SettingInfo : FormField {
    let key : String
    let imageURL : URL?
}
