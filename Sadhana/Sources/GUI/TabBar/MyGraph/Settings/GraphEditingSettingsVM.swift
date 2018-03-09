//
//  GraphEditingSettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/28/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

class GraphEditingSettingsVM : BaseSettingsVM {
    //TODO: Localize
    override var title : String? { return "Graph Editing" }

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

        //TODO: localize
        sections.append(SettingsSection(title: "My Graph", items: items))

        //TODO: localize
        let bedTimeSetting = DataFormFieldVM(title: "Show bed time for yesterday",
                                                 type: .switcher,
                                                 variable: KeyPathVariable(Local.defaults, \LocalDefaults.showBedTimeForYesterday))
        let bedTimeSection = SettingsSection(title: "", items: [bedTimeSetting])
        sections.append(bedTimeSection)

        bedTimeEnabledItem.variable.subscribe(onNext: { [weak self] (shown) in
            bedTimeSection.shown = shown
            self?.updates.onNext(())
        }).disposed(by: disposeBag)


        //TODO: localize
        let readingInMinutesSetting =
            DataFormFieldVM(title: "Fill reading only in minutes",
                            type: .switcher,
                            variable: KeyPathVariable(Local.defaults, \LocalDefaults.readingOnlyInMinutes))
        addSingle(item: readingInMinutesSetting)
    }
}
