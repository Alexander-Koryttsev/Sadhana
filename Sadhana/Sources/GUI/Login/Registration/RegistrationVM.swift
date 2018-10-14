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
    override init() {

        let localDisposeBag = DisposeBag()
        var fields = [FormFieldVM]()
        let registration = Registration()
        let validator = Validator()
        let registerDriver = register.take(1).asDriver(onErrorJustReturn: ())

        let spiritNameField = DataFormFieldVM(title: "spiritutal_name".localized,
                                                  type: .text(.name(.spiritual)),
                                                  variable: KeyPathVariable(registration, \Registration.spiritualName),
                                                  validSelector: validator.validate(spirutalName:))

        fields.append(spiritNameField)

        let firstNameField = DataFormFieldVM(title: "first_name".localized,
                                                 type: .text(.name(.first)),
                                                 variable: KeyPathVariable(registration, \Registration.firstName),
                                                 validSelector: validator.validate(string:),
                                                 beginValidation: registerDriver)

        fields.append(firstNameField)

        let lastNameField = DataFormFieldVM(title: "last_name".localized,
                                                 type: .text(.name(.last)),
                                                 variable: KeyPathVariable(registration, \Registration.lastName),
                                                 validSelector: validator.validate(string:),
                                                 beginValidation: registerDriver)
        fields.append(lastNameField)

        let emailField = DataFormFieldVM(title: "email".localized,
                                                type: .text(.email),
                                                variable: KeyPathVariable(registration, \Registration.email),
                                                validSelector: validator.validate(email:),
                                                beginValidation: registerDriver)
        fields.append(emailField)

        let passwordField = DataFormFieldVM(title: "password".localized,
                                             type: .text(.password),
                                             variable: KeyPathVariable(registration, \Registration.password))

        let passwordConfirmationField = DataFormFieldVM(title: "confirm_password".localized,
                                                        type: .text(.password),
                                                        variable: StoredVariable(""))

        let passwordValid = Observable.combineLatest(passwordField.variable.asObservable(),
                                                     passwordConfirmationField.variable.asObservable(),
                                                     resultSelector: validator.validate(password:confirmation:))
        let passwordValidSimple = passwordValid.map { (flag, _) in flag }.asDriver(onErrorJustReturn: false)

        fields.append(passwordField)
        fields.append(passwordConfirmationField)


        var countryField = DataFormFieldVM(title: "country".localized,
                                    type: .picker,
                                    variable: StoredVariable<Titled?>(nil),
                                    validSelector:validator.validate,
                                    beginValidation:registerDriver)

        var cityField = DataFormFieldVM(title: "city".localized,
                                           type: .picker,
                                           variable: StoredVariable<Titled?>(nil),
                                           validSelector:validator.validate,
                                           beginValidation:registerDriver)

        cityField.action = {
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

        countryField.action = {
            let pickerVM = FormPickerVM(fieldVM: countryField, load:Remote.service.loadCountries())
            RootRouter.shared?.show(picker: pickerVM)
            return true
        }

        countryField.variable.distinctUntilChanged({ (country1, country2) -> Bool in
            guard let country1 = country1,
                let country2 = country2
            else {
                return false
            }
            return country1.title == country2.title
        }).map { _ in
            return nil
            }.bind(to:cityField.variable).disposed(by: localDisposeBag)

        countryField.variable.subscribe(onNext:{ (country) in
            registration.country = country?.title ?? ""
        }).disposed(by: localDisposeBag);
        fields.append(countryField)

        cityField.variable.subscribe(onNext:{ (city) in
            registration.city = city?.title ?? ""
        }).disposed(by: localDisposeBag);
        fields.append(cityField)


        let dateField = DataFormFieldVM(title: "birthday".localized,
                                            type: .date(min:Calendar.current.date(byAdding: .year, value: -100, to: Date()),
                                                        default:Calendar.current.date(byAdding: .year, value: -20, to: Date()),
                                                        max:Calendar.current.date(byAdding: .year, value: -5, to: Date())),
                                        variable: KeyPathVariable(registration, \Registration.birthday),
                                        validSelector: validator.validate,
                                        beginValidation: registerDriver)

        fields.append(dateField)

        canRegister = Driver.combineLatest(spiritNameField.valid!,
                                           firstNameField.valid!,
                                           lastNameField.valid!,
                                           passwordValidSimple,
                                           emailField.valid!,
                                           countryField.valid!,
                                           cityField.valid!,
                                           dateField.valid!) {  spiritNameValid,
                                                                firstNameValid,
                                                                lastNameValid,
                                                                passwordValid,
                                                                emailValid,
                                                                countryValid,
                                                                cityValid,
                                                                dateValid in

            return  spiritNameValid &&
                    firstNameValid &&
                    lastNameValid &&
                    passwordValid &&
                    emailValid &&
                    countryValid &&
                    cityValid &&
                    dateValid
        }.distinctUntilChanged()

        sections = [
            Section(fields: [ spiritNameField,
                              firstNameField,
                              lastNameField,
                              emailField ],
                    footer:nil),
            Section(fields: [ passwordField,
                              passwordConfirmationField],
                    footer: passwordValid.map { (_, string) in string }.asDriver(onErrorJustReturn: "")),
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
                        .do(onNext: { _ in
                            RootRouter.shared?.commitSignIn()
                        })
                        .asBoolNoErrorObservable()
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
