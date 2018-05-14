//
//  GraphEditingSettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/28/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import MessageUI

class GraphEditingSettingsVM : BaseSettingsVM {
    override var title : String? { return "my_graph".localized }

    override init(_ router: MyGraphRouter) {
        super.init(router)

        let user = Main.service.currentUser!
        let bedTimeEnabledItem = DataFormFieldVM(title: EntryFieldKey.bedTime.rawValue.localized,
                                                     type: .switcher,
                                                     variable: AutoSaveKeyPathVariable(user, \ManagedUser.bedTimeEnabled))
        let items = [
            DataFormFieldVM(title: EntryFieldKey.wakeUpTime.rawValue.localized,
                                type: .switcher,
                                variable: AutoSaveKeyPathVariable(user, \ManagedUser.wakeUpTimeEnabled)),
            bedTimeEnabledItem,

            DataFormFieldVM(title: EntryFieldKey.yoga.rawValue.localized,
                            type: .switcher,
                            variable: AutoSaveKeyPathVariable(user, \ManagedUser.exerciseEnabled)),

            DataFormFieldVM(title: EntryFieldKey.service.rawValue.localized,
                            type: .switcher,
                            variable: AutoSaveKeyPathVariable(user, \ManagedUser.serviceEnabled)),

            DataFormFieldVM(title: EntryFieldKey.lections.rawValue.localized,
                            type: .switcher,
                            variable: AutoSaveKeyPathVariable(user, \ManagedUser.lectionsEnabled))
            ]

        sections.append(SettingsSection(title: "settings.fields".localized, items: items))

        let bedTimeSetting = DataFormFieldVM(title: "settings.bed_time_yesterday".localized,
                                                 type: .switcher,
                                                 variable: KeyPathVariable(Local.defaults, \LocalDefaults.showBedTimeForYesterday))
        let bedTimeSection = SettingsSection(title: "", items: [bedTimeSetting])
        sections.append(bedTimeSection)

        bedTimeEnabledItem.variable.subscribe(onNext: { [weak self] (shown) in
            bedTimeSection.shown = shown
            self?.updates.onNext(())
        }).disposed(by: disposeBag)

        let readingInMinutesSetting =
            DataFormFieldVM(title: "settings.reading_in_minutes".localized,
                            type: .switcher,
                            variable: KeyPathVariable(Local.defaults, \LocalDefaults.readingOnlyInMinutes))
        addSingle(item: readingInMinutesSetting)

        let manualKeyboardSetting =
            DataFormFieldVM(title: "settings.manual_keyboard".localized,
                            type: .switcher,
                            variable: KeyPathVariable(Local.defaults, \LocalDefaults.manualKeyboardEnabled))
        addSingle(item: manualKeyboardSetting)

        addFeedbackItem()
    }

    func addFeedbackItem() {
        let action = FormAction(title: "settings.suggest".localized, actionType:.basic, presenter:true) { [unowned self] in
            let address = "feedback.sadhana@gmail.com"
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.setToRecipients([address])
                mailComposerVC.title = "settings.suggest".localized
                mailComposerVC.setSubject("settings.suggestion".localized)
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
            return false
        }

        addSingle(item: action)
    }
}
