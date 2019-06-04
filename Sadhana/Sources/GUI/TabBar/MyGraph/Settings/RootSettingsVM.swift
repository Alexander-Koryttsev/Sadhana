//
//  RootSettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import MessageUI
import Crashlytics

class RootSettingsVM : BaseSettingsVM {
    override var title : String? { return "settings".localized }
    private var signingOut = false

    override init(_ router: MyGraphRouter) {
        super.init(router)

        addUserInfoSection()
        //addCommonSection()
        addMyGraphSection()
        addFeedbackItem()

        #if DEV || DEBUG
            addDevSection()
        #endif

        addSignOutItem()
    }

    deinit {
        if !signingOut {
            //TODO: make user Syncable
            if let user = Main.service.currentUser {
                _ = Remote.service.send(user).subscribe()
            }
            Local.service.viewContext.saveHandled()
        }
    }

    func addUserInfoSection() {
        if let user = Main.service.currentUser {
            let userInfo = SettingInfo(title: "", variable: KeyPathVariable(user, \ManagedUser.name), imageURL: user.avatarURL, action:{ [weak self] () -> Bool in
                self?.router.showProfileSettings()
                return false
            })
            addSingle(item: userInfo)
        }
    }

    func addCommonSection() {
        let user = Main.service.currentUser!

        let items = [
            DataFormFieldVM(title: "settings.show_on_main_page".localized,
                            type: .switcher,
                            variable: AutoSaveKeyPathVariable(user, \ManagedUser.isPublic)),
            DataFormFieldVM(title: "settings.show_more_16".localized,
                            type: .switcher,
                            variable: AutoSaveKeyPathVariable(user, \ManagedUser.showMore16))
        ]

        sections.append(SettingsSection(title: "", items: items))
    }

    func addMyGraphSection() {
        let action = FormAction(title: "my_graph".localized, actionType: .detail, presenter: false) { [weak self] in
            self?.router.showGraphEditingSettings()
            return true
        }

        let exportCSV = FormAction(title: "settings.export_csv".localized, actionType: .basic, presenter: true) { [weak self] in
            self?.router.showCSVExport()
            return true
        }

        sections.append(SettingsSection(title: "", items: [action, exportCSV], footer: "settings.export_csv_footer".localized))
    }

    func addFeedbackItem() {
        let action = FormAction(title: "letterToDevs".localized, actionType:.basic, presenter:true) { [unowned self] in
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
                Answers.logContentView(withName: "Feedback", contentType: nil, contentId: nil, customAttributes: nil)
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
            return false
        }

        addSingle(item: action)
    }

    func addDevSection() {
        let restartGuide = FormAction(title: "settings.restart_guide".localized, actionType:.basic, presenter: false) { [unowned self] () in
            Local.defaults.resetGuide()
            self.router.parent?.tabBarVC?.viewDidAppear(true)
            return true
        }

        let tokens = FormAction(title: "Долбануть токены", actionType: .destructive, presenter: false) { () -> Bool in
            Remote.service.clearTokens()
            return true
        }

        sections.append(SettingsSection(title: "settings.developer".localized, items: [restartGuide, tokens]))
    }

    func addSignOutItem() {
        let logoutAction = FormAction(title: "signOut".localized, actionType:.destructive, presenter: false) { [unowned self] in
            let alert = Alert()
            alert.add(action:"signOut".localized, style: .destructive, handler: { [weak self] in
                self?.signingOut = true
                RootRouter.shared?.logOut()
            })

            alert.addCancelAction()
            self.alerts.onNext(alert)
            return false
        }
        addSingle(item: logoutAction)
    }
}
