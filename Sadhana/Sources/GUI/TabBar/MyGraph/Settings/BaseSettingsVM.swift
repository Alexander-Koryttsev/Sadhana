//
//  BaseSettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/28/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

class BaseSettingsVM : BaseTableVM {

    unowned let router : MyGraphRouter
    var sections = [SettingsSection]()
    var title : String? {  return "" }
    let updates = PublishSubject<Void>()

    init(_ router: MyGraphRouter) {
        self.router = router
        super.init()
    }

    func addSingle(item: FormFieldVM, title: String? = "") {
        sections.append(SettingsSection(title: title!, items: [item]))
    }
}

class SettingsSection {
    let headerTitle : String
    let items : [FormFieldVM]
    var shown = true
    let footerTitle : String

    init(title: String, items: [FormFieldVM], footer: String = "") {
        self.headerTitle = title
        self.items = items
        self.footerTitle = footer
    }
}

struct FormAction : FormFieldVM {
    let title : String
    let actionType : ActionType
    let presenter : Bool
    let action: (() -> Bool)?

    var type : FormFieldType {
        return .action(actionType)
    }
}

struct SettingInfo : FormFieldVM {
    let title : String
    let variable : Variable<String>
    let imageURL : URL?
    let type = FormFieldType.profileInfo
    let action: (() -> Bool)?
}
