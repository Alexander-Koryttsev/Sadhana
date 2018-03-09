//
//  ProfileSettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/28/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

class ProfileEditingSettingsVM : BaseSettingsVM {
    //TODO: Localize
    override var title : String? { return "Profile" }
    let validator = Validator()
    private let context = Local.service.newSubViewForegroundContext()
    private let user : ManagedUser

    override init(_ router: MyGraphRouter) {
        user = context.fetchUser(for: Local.defaults.userID!)!
        super.init(router)

        let spiritNameField = DataFormFieldVM(title: "spiritutal_name".localized,
                                              type: .text(.name(.spiritual)),
                                              variable: KeyPathVariable(user, \ManagedUser.spiritualName),
                                              validSelector: validator.validate(spirutalName:))

        let firstNameField = DataFormFieldVM(title: "first_name".localized,
                                             type: .text(.name(.first)),
                                             variable: KeyPathVariable(user, \ManagedUser.firstName),
                                             validSelector: validator.validate(string:))

        let lastNameField = DataFormFieldVM(title: "last_name".localized,
                                            type: .text(.name(.last)),
                                            variable: KeyPathVariable(user, \ManagedUser.lastName),
                                            validSelector: validator.validate(string:))

        sections.append(SettingsSection(title: "", items: [spiritNameField, firstNameField, lastNameField]))
        
        let loginField = DataFormFieldVM(title: "login".localized,
                                              type: .text(.basic),
                                              variable: KeyPathVariable(user, \ManagedUser.login),
                                              enabled: false)
        
        let emailField = DataFormFieldVM(title: "email".localized,
                                         type: .text(.email),
                                         variable: KeyPathVariable(user, \ManagedUser.email),
                                         enabled: false)
        
        let registrationDateField = DataFormFieldVM(title: "registration_date".localized,
                                            type: .date(min: nil, default: nil, max: nil),
                                            variable: KeyPathVariable(user, \ManagedUser.registrationDateOptional),
                                            enabled: false)
        
        sections.append(SettingsSection(title: "", items: [loginField, emailField, registrationDateField]))
    }

    deinit {
        if user.hasPersistentChangedValues,
            validator.validate(spirutalName: user.spiritualName),
            validator.validate(string: user.firstName),
            validator.validate(string: user.lastName)
        {
            _ = Remote.service.send(profile: user).subscribe()
            context.saveHandledRecursive()
        }
    }
}
