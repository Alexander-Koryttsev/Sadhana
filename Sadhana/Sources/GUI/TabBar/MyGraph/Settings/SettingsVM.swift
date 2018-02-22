//
//  SettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa

import MessageUI
import Crashlytics


class SettingsVM : BaseTableVM {

    unowned let router : MyGraphRouter
    var sections = [SettingsSection]()

    init(_ router: MyGraphRouter) {
        self.router = router
        super.init()

        addUserInfoSection()
        //addCommonSection()
       // addMyGraphSection()
        addFeedbackItem()

        #if DEV
            addDevSection()
        #endif

        addSignOutItem()
    }

    deinit {
      //  if let user = Main.service.user as? ManagedUser {
        //    _ = Remote.service.send(user).subscribe()
        //}
    }

    func addUserInfoSection() {
        if let user = Main.service.currentUser {
            let userInfo = SettingInfo(key: user.name, imageURL: user.avatarURL)
            addSingle(item: userInfo)
        }
    }

    func addCommonSection() {
        if let user = Main.service.currentUser {
            //TODO: Localize
            let publicItem = KeyPathFieldVM(user, \ManagedUser.isPublic, for:"isPublic", type:.switcher)
            publicItem.variable.asDriver().drive(onNext:{ _ in
                user.managedObjectContext?.saveHanlded()
            }).disposed(by: disposeBag)

            sections.append(SettingsSection(title: "Common Settings", items: [publicItem]))
        }
    }

    func addMyGraphSection() {
       // if let user = Main.service.user as? ManagedUser {
            let items = [
                myGraphItem(for: .wakeUpTime),
                myGraphItem(for: .bedTime),
                myGraphItem(for: .yoga),
                myGraphItem(for: .service),
                myGraphItem(for: .lections)
            ]

            sections.append(SettingsSection(title: "My Graph", items: items))
       // }
    }

    func myGraphItem(for key: EntryFieldKey) -> FormFieldVM {
        let variable = Variable(Local.defaults.isFieldEnabled(key))
        variable.asDriver().drive(onNext: { (value) in
            Local.defaults.set(field: key, enabled: value)
        }).disposed(by: disposeBag)
        return VariableFieldVM(variable, for: key.rawValue, type:.switcher)
    }

    func addFeedbackItem() {
        let action = FormAction(key: "letterToDevs".localized, actionType:.basic, presenter:true) { [unowned self] in
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
        }

        addSingle(item: action)
    }

    func addDevSection() {
        let restartGuide = FormAction(key: "Restart Guide", actionType:.basic, presenter: false) { [unowned self] () in
            Local.defaults.resetGuide()
            self.router.parent?.tabBarVC?.viewDidAppear(true)
        }

        addSingle(item: restartGuide, title: "Developer")
    }

    func addSignOutItem() {
        let logoutAction = FormAction(key: "signOut".localized, actionType:.destructive, presenter: false) { [unowned self] in
            let alert = Alert()
            alert.add(action:"signOut".localized, style: .destructive, handler: {
                RootRouter.shared?.logOut()
            })

            alert.addCancelAction()
            self.alerts.onNext(alert)
        }
        addSingle(item: logoutAction)
    }

    func addSingle(item: FormFieldVM, title: String? = "") {
        sections.append(SettingsSection(title: title!, items: [item]))
    }
}

struct SettingsSection {
    let title : String
    let items : [FormFieldVM]
}

struct FormAction : FormFieldVM {
    let key : String
    let actionType : ActionType
    let presenter : Bool
    let action : Block

    var type : FormFieldType {
        return .action(actionType)
    }
}

struct SettingInfo : FormFieldVM {
    let key : String
    let imageURL : URL?
    let type = FormFieldType.profileInfo
}
