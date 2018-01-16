//
//  RegistrationVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/4/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa

class RegistrationVM: BaseTableVM {
    let fields : [FormFieldVM]
    private let registration : Registration
    let canRegister : Driver<Bool>
    let passwordValid : Driver<Bool>
    let localDisposeBag : DisposeBag
    let activityIndicator = ActivityIndicator()
    let register = PublishSubject<Void>()
    let validator : Validator
    override init() {

        let localDisposeBag = DisposeBag()
        var fields = [FormFieldVM]()
        let registration = Registration()
        let validator = Validator()

        let spiritNameField = KeyPathFieldVM(registration, \Registration.spiritualName, for: "spiritutal_name".localized, type:.text(.name))
        fields.append(spiritNameField)

        let firstNameField = KeyPathFieldVM(registration, \Registration.firstName, for: "first_name".localized, type:.text(.name), validSelector:validator.validate(string:))
        fields.append(firstNameField)

        let lastNameField = KeyPathFieldVM(registration, \Registration.lastName, for: "last_name".localized, type:.text(.name), validSelector:validator.validate(string:))
        fields.append(lastNameField)

        let emailField = KeyPathFieldVM(registration, \Registration.email, for: "email".localized, type:.text(.email), validSelector:validator.validate(email:))
        fields.append(emailField)

        let passwordField = KeyPathFieldVM(registration, \Registration.password, for: "password".localized, type:.text(.password))
        let passwordConfirmationField = VariableFieldVM(Variable(""), for: "confirm_password".localized, type:.text(.password))

        let passwordValid = Driver.combineLatest(passwordField.variable.asDriver(), passwordConfirmationField.variable.asDriver(), resultSelector: validator.validate(password:confirmation:)).distinctUntilChanged()

        fields.append(passwordField)
        fields.append(passwordConfirmationField)

        let countryField = PickerFieldVM(Variable<Titled?>(nil), for: "country".localized, validSelector:validator.validate)
        let cityField = PickerFieldVM(Variable<Titled?>(nil), for: "city".localized, validSelector:validator.validate)

        cityField.action = { [unowned cityField] in
            if let country = countryField.variable.value as? Country {
                let pickerVM = FormPickerVM(fieldVM: cityField, load:Remote.service.loadCities(countryID: country.ID))
                pickerVM.select.subscribe({_ in
                    RootRouter.shared?.hidePicker()
                }).disposed(by: pickerVM.disposeBag)

                RootRouter.shared?.show(picker: pickerVM)
                return true
            }
            return false
        }

        countryField.action = { [unowned countryField] in
            let pickerVM = FormPickerVM(fieldVM: countryField, load:Remote.service.loadCountries())
            RootRouter.shared?.show(picker: pickerVM)
            return true
        }

        countryField.variable.asDriver().distinctUntilChanged({ (country1, country2) -> Bool in
            guard let country1 = country1,
                let country2 = country2
            else {
                return false
            }
            return country1.title == country2.title
        }).map { _ in
            return nil
        }.drive(cityField.variable).disposed(by: localDisposeBag)

        countryField.variable.asDriver().drive(onNext:{ (country) in
            registration.country = country?.title ?? ""
        }).disposed(by: localDisposeBag);
        fields.append(countryField)

        cityField.variable.asDriver().drive(onNext:{ (city) in
            registration.city = city?.title ?? ""
        }).disposed(by: localDisposeBag);
        fields.append(cityField)

        let dateField = KeyPathFieldVM(registration, \Registration.birthday,
                                       for: "birthday".localized,
                                       type:.date(min:Calendar.local.date(byAdding: .year, value: -100, to: Date()),
                                                  default:Calendar.local.date(byAdding: .year, value: -20, to: Date()),
                                                  max:Calendar.local.date(byAdding: .year, value: -5, to: Date())),
                                       validSelector:validator.validate)
        fields.append(dateField)

        canRegister = Driver.combineLatest(firstNameField.valid!,
                                           lastNameField.valid!,
                                           passwordValid,
                                           emailField.valid!,
                                           countryField.valid!,
                                           cityField.valid!,
                                           dateField.valid!) { firstNameValid, lastNameValid, passwordValid, emailValid, countryValid, cityValid, dateValid  in

            return firstNameValid && lastNameValid && passwordValid && emailValid && countryValid && cityValid && dateValid
        }.distinctUntilChanged()

        self.fields = fields
        self.localDisposeBag = localDisposeBag
        self.registration = registration
        self.validator = validator
        self.passwordValid = passwordValid
        super.init()

        register.withLatestFrom(canRegister)
            .filter { [unowned self] valid in
                if !valid {
                    DispatchQueue.main.async {
                        self.messages.onNext("Пожалуйста, заполните все поля") //TODO: Localize
                    }
                }
                return valid
            }
            .flatMap { [unowned self] _ in
                return Main.service.register(self.registration)
                        .observeOn(MainScheduler.instance)
                        .track(self.errors)
                        .track(self.activityIndicator)
                        .do(onNext: { _ in
                            RootRouter.shared?.commitSignIn()
                        })
                        .asBoolObservable()
                        .catchErrorJustReturn(false)
                 }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

class Validator {
    func validate(string:String) -> Bool {
        return string.count > 0
    }

    let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    func validate(email:String) -> Bool {
        return email.count > 0 && emailTest.evaluate(with: email)
    }

    func validate(password:String, confirmation:String) -> Bool {
        return password.count > 0 && password == confirmation
    }

    func validate(_ any:Any?) -> Bool {
        return any != nil
    }
}
