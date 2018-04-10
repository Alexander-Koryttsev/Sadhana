//
//  RegistrationVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/4/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//




class RegistrationVM: BaseTableVM {

    struct Section {
        let fields : [FormFieldVM]
        let footer : Driver<String>?
    }

    let fields : [FormFieldVM]
    let sections : [Section]
    private let registration : Registration
    let canRegister : Driver<Bool>
    let passwordValid : Driver<Bool>
    let localDisposeBag : DisposeBag
    let activityIndicator = ActivityIndicator()
    let register = PublishSubject<Void>()
    let validator : Validator
    let tapticEngine = UINotificationFeedbackGenerator()
    override init() {

        let localDisposeBag = DisposeBag()
        var fields = [FormFieldVM]()
        let registration = Registration()
        let validator = Validator()
        let registerDriver = register.take(1).asDriver(onErrorJustReturn: ())

        let spiritNameField = KeyPathFieldVM(registration, \Registration.spiritualName, for: "spiritutal_name".localized, type:.text(.name(.spiritual)), validSelector:validator.validate(spirutalName:))
        fields.append(spiritNameField)

        let firstNameField = KeyPathFieldVM(registration, \Registration.firstName, for: "first_name".localized, type:.text(.name(.first)), validSelector:validator.validate(string:))
        firstNameField.beginValidation = registerDriver
        fields.append(firstNameField)

        let lastNameField = KeyPathFieldVM(registration, \Registration.lastName, for: "last_name".localized, type:.text(.name(.last)), validSelector:validator.validate(string:))
        lastNameField.beginValidation = registerDriver
        fields.append(lastNameField)

        let emailField = KeyPathFieldVM(registration, \Registration.email, for: "email".localized, type:.text(.email), validSelector:validator.validate(email:))
        emailField.beginValidation = registerDriver
        fields.append(emailField)

        let passwordField = KeyPathFieldVM(registration, \Registration.password, for: "password".localized, type:.text(.password))
        let passwordConfirmationField = VariableFieldVM(Variable(""), for: "confirm_password".localized, type:.text(.password))

        let passwordValid = Driver.combineLatest(passwordField.variable.asDriver(), passwordConfirmationField.variable.asDriver(), resultSelector: validator.validate(password:confirmation:))
        let passwordValidSimple = passwordValid.map { (flag, _) in flag }

        fields.append(passwordField)
        fields.append(passwordConfirmationField)

        let countryField = PickerFieldVM(Variable<Titled?>(nil), for: "country".localized, validSelector:validator.validate)
        countryField.beginValidation = registerDriver
        let cityField = PickerFieldVM(Variable<Titled?>(nil), for: "city".localized, validSelector:validator.validate)
        cityField.beginValidation = registerDriver
        cityField.action = { [unowned cityField] in
            if let country = countryField.variable.value as? Country {
                let pickerVM = FormPickerVM(fieldVM: cityField, searchSelector:{ string in
                    return Remote.service.loadCities(countryID: country.ID, query:string)
                })
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
                                       type:.date(min:Calendar.current.date(byAdding: .year, value: -100, to: Date()),
                                                  default:Calendar.current.date(byAdding: .year, value: -20, to: Date()),
                                                  max:Calendar.current.date(byAdding: .year, value: -5, to: Date())),
                                       validSelector:validator.validate)
        dateField.beginValidation = registerDriver
        fields.append(dateField)

        canRegister = Driver.combineLatest(spiritNameField.valid!,
                                           firstNameField.valid!,
                                           lastNameField.valid!,
                                           passwordValidSimple,
                                           emailField.valid!,
                                           countryField.valid!,
                                           cityField.valid!,
                                           dateField.valid!) { spiritNameValid, firstNameValid, lastNameValid, passwordValid, emailValid, countryValid, cityValid, dateValid  in

            return spiritNameValid && firstNameValid && lastNameValid && passwordValid && emailValid && countryValid && cityValid && dateValid
        }.distinctUntilChanged()

        sections = [
            Section(fields: [ spiritNameField,
                              firstNameField,
                              lastNameField,
                              emailField ],
                    footer:nil),
            Section(fields: [ passwordField,
                              passwordConfirmationField],
                    footer: passwordValid.map { (_, string) in string }),
            Section(fields: [ countryField,
                              cityField,
                              dateField],
                    footer:nil),
        ]

        self.fields = fields
        self.localDisposeBag = localDisposeBag
        self.registration = registration
        self.validator = validator
        self.passwordValid = passwordValidSimple
        super.init()

        register.withLatestFrom(canRegister)
            .filter { [unowned self] valid in
                if !valid {
                    DispatchQueue.main.async {
                        self.messages.onNext("empty_fields_warning".localized)
                        self.tapticEngine.notificationOccurred(.warning)
                    }
                }
                return valid
            }
            .flatMap { [unowned self] _ in
                return Main.service.register(self.registration)
                        .observeOn(MainScheduler.instance)
                        .track(self.errors)
                        .track(self.activityIndicator)
                        .do(onSuccess: { _ in
                            RootRouter.shared?.commitSignIn()
                        })
                        .asBoolObservable()
                 }
            .subscribe(onNext:{ [weak self] (success) in
                 self?.tapticEngine.notificationOccurred(success ? .success : .error)
            })
            .disposed(by: disposeBag)
    }
}

class Validator {
    func validate(string:String) -> Bool {
        return string.count > 2
    }

    func validate(spirutalName:String) -> Bool {
        return spirutalName.count == 0 || spirutalName.count > 2
    }

    let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    func validate(email:String) -> Bool {
        return email.count > 0 && emailTest.evaluate(with: email)
    }

    func validate(password:String, confirmation:String) -> (Bool, String) {

        if password.count < 8 {
            return (false, "password_short".localized)
        }

        if password != confirmation {
            return (false, "passwords_not_equal".localized)
        }

        return (true, "👍")
    }

    func validate(_ any:Any?) -> Bool {
        return any != nil
    }
}
