//
//  LoginVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//




import EasyPeasy

class LoginVC: BaseVC<LoginVM>, UITextFieldDelegate {
    let logo = UIImageView(screenSized:"icon")
    let darkBackground = UIView()
    let formArea = UIView()
    let titleLabel = UILabel()
    let formContainer = UIView()
    let form = UIView()
    let loginField = UITextField()
    let passwordField = UITextField()
    let loginButton = Button()
    let arrow = UIImageView(image:#imageLiteral(resourceName: "login-arrow"))
    let errorLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let registerButton = UIButton(type: .system)
    let sevaLogo = UIImageView(screenSized:"v-seva-logo")

    override init(_ viewModel: VM) {
        super.init(viewModel)
        base.defaultErrorMessagingEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
        setUpSubviews()
        buildConstraints()
        animateForm()
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { get { return UIStatusBarStyle.lightContent } }

    func setUpSubviews() {
        setUpBackground()
        setUpFormAndLogo()
        setUpActivityIndicator()
        setUpErrorLabel()
        setUpRegisterButton()
    }

    func setUpBackground() {
        let gradient = RadialGradientView()
        view.addSubview(gradient)
        gradient.easy.layout(Edges())

        let prabhupada = UIImageView(screenSized:"prabhupada")
        prabhupada.contentMode = .center
        view.addSubview(prabhupada)
        prabhupada.easy.layout([
            Left(),
            Top(),
            Right()
        ])

        sevaLogo.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.addSubview(sevaLogo)
        sevaLogo.easy.layout([
            Right(screenWidthSpecific(w320: 12, w375: 14, w414: 21)),
            Bottom(screenWidthSpecific(w320: 12, w375: 14, w414: 21)).to(view, .bottomMargin)
        ])

        view.addSubview(darkBackground)
        darkBackground.backgroundColor = .black
        darkBackground.alpha = 0
        darkBackground.easy.layout(Edges())
    }

    func setUpLogo() {
        formArea.addSubview(logo)
        formArea.addSubview(titleLabel)
        titleLabel.text = "sadhana".localized
        titleLabel.font = UIFont.sdTextStyle1Font()
        titleLabel.textColor = UIColor.white
    }

    func setUpFormAndLogo() {
        view.addSubview(formArea)
        formArea.backgroundColor = UIColor.clear

        formArea.addSubview(formContainer)
        formContainer.layer.shadowOpacity = 1
        formContainer.layer.shadowRadius = 5
        formContainer.layer.shadowColor = UIColor.sdMudBrown12.cgColor
        formContainer.layer.shadowOffset = CGSize(width: 0, height: 1)

        formContainer.addSubview(form)
        form.backgroundColor = UIColor.white
        form.clipsToBounds = true
        form.layer.cornerRadius = 5
        form.easy.layout(Edges())

        setUpLoginField()
        setUpPasswordField()
        setUpLoginButton()
        setUpLogo()
    }

    func setUpLoginField(){
        form.addSubview(loginField)
        loginField.placeholder = "login.login".localized
        loginField.borderStyle = .none
        loginField.textAlignment = .center
        loginField.font = UIFont.sdTextStyle3Font()
        loginField.keyboardAppearance = .dark
        loginField.autocorrectionType = .no
        loginField.keyboardType = .emailAddress
        loginField.returnKeyType = .next
        loginField.delegate = self
        if #available(iOS 11, *) {
            loginField.textContentType = .username
        }
        loginField.easy.layout([
            Top(),
            Left(8),
            Right(8),
            Height(44)
        ])
    }
    
    func setUpPasswordField() {
        let separator = UIView()
        form.addSubview(separator)
        separator.backgroundColor = .sdPaleGrey
        separator.easy.layout([
            Top().to(loginField),
            Left().to(loginField, .left),
            Right().to(loginField, .right),
            Height(1),
        ])

        form.addSubview(passwordField)
        passwordField.placeholder = "password".localized
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = loginField.borderStyle
        passwordField.textAlignment = loginField.textAlignment
        passwordField.font = loginField.font
        passwordField.keyboardAppearance = loginField.keyboardAppearance
        passwordField.returnKeyType = .go
        passwordField.enablesReturnKeyAutomatically = true
        passwordField.delegate = self
        if #available(iOS 11, *) {
            loginField.textContentType = .password
        }
        passwordField.easy.layout([
            Top().to(separator),
            Left().to(loginField, .left),
            Right().to(loginField, .right),
            Height().like(loginField)
        ])
    }

    func setUpLoginButton() {
        form.addSubview(loginButton)
        loginButton.setTitle("sign_in".localized, for: .normal)
        loginButton.titleLabel?.font = UIFont.sdTextStyle2Font()
        loginButton.easy.layout([
            Top().to(passwordField),
            Left(),
            Right(),
            Height(59),
            Bottom(0)
        ])

        loginButton.addSubview(arrow)
        arrow.easy.layout([
            CenterY().to(loginButton.titleLabel!),
            Left(10).to(loginButton.titleLabel!, .right)
        ])
    }

    func setUpActivityIndicator() {
        form.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.easy.layout([
            CenterX().to(loginButton),
            CenterY().to(loginButton)
        ])
    }

    func setUpErrorLabel() {
        formArea.addSubview(errorLabel)
        errorLabel.numberOfLines = 0
        errorLabel.textColor = UIColor.white
        errorLabel.textAlignment = .center
        errorLabel.text = ""
        errorLabel.easy.layout([
            Top(12).to(formContainer),
            CenterX(),
            Width(280)
        ])
    }

    func setUpRegisterButton() {
        registerButton.tintColor = .white
        registerButton.setAttributedTitle(NSAttributedString(string: "register".localized, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue as AnyObject]), for: .normal)
        registerButton.titleLabel?.font = .sdTextStyle3Font()
        registerButton.alpha = 0
        registerButton.addTarget(viewModel, action: #selector(LoginVM.register), for: .touchUpInside)

        view.addSubview(registerButton)
        registerButton.easy.layout([Height(50),
                                    CenterY().to(sevaLogo),
                                    CenterX(),
                                    Width().like(formContainer)])
        registerButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    func buildConstraints() {
        formArea.easy.layout([
            Top(),
            Left(),
            Right(),
            Bottom(0)
        ])

        logo.easy.layout(Center().with(.high))

        titleLabel.easy.layout([
            Top().to(logo),
            CenterX()
        ])

        formContainer.easy.layout([
            Top(22).to(titleLabel),
            Width(280),
            CenterX()
        ])
    }

    func animateForm() {
        formContainer.alpha = 0
        errorLabel.alpha = 0
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.formContainer.easy.layout(Top(-5).to(self.formArea, .centerY))
            self.titleLabel.easy.layout(Bottom(22).to(self.formContainer))

            UIView.animate(withDuration: 1.5, animations: {
                self.formArea.layoutIfNeeded()
                self.formContainer.alpha = 1
                self.errorLabel.alpha = 1
                self.registerButton.alpha = 1
            })
        })
    }

    @objc func keyboardWillChange(notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboarFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let shown = keyboarFrame.origin.y < UIScreen.main.bounds.size.height

        UIView.animate(withDuration: 0.3) {
            self.formArea.easy.layout(Bottom(shown ? keyboarFrame.size.height : 0))
            self.view.layoutIfNeeded()
            self.darkBackground.alpha = shown ? 0.3 : 0
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginField {
            passwordField.becomeFirstResponder()
            return false
        }
        if textField == passwordField {
            viewModel.tap.onNext(())
        }
        return true
    }
    
    override func bindViewModel() {
        super.bindViewModel()

        //Login Form
        loginField.text = viewModel.login.value
        loginField.rx.textRequired.asDriver().distinctUntilChanged()
            .do(onNext:{ [weak self] _ in self?.errorLabel.text = nil})
            .drive(viewModel.login).disposed(by: disposeBag)

        passwordField.text = viewModel.password.value
        passwordField.rx.textRequired.asDriver().distinctUntilChanged()
            .do(onNext:{ [weak self] _ in self?.errorLabel.text = nil})
            .drive(viewModel.password).disposed(by: disposeBag)

        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.loginField.resignFirstResponder()
                self?.passwordField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)

        loginButton.rx.tap.asDriver()
            .do(onNext:{ [weak self] () in self?.errorLabel.text = nil})
            .drive(viewModel.tap).disposed(by: disposeBag)

        viewModel.canSignIn.drive(loginButton.rx.isEnabled).disposed(by: disposeBag)

        //Activity
        viewModel.activityIndicator.drive(activityIndicator.rx.isAnimating).disposed(by: disposeBag)
        viewModel.activityIndicator.drive(arrow.rx.isHidden).disposed(by: disposeBag)

        let enabled = viewModel.activityIndicator
            .map({ (animating) -> Bool in  return !animating })

        enabled.drive(loginField.rx.isEnabled).disposed(by: disposeBag)
        enabled.drive(passwordField.rx.isEnabled).disposed(by: disposeBag)
        enabled.map { $0 ? 1.0 : 0.0 }.drive(loginButton.titleLabel!.rx.alpha).disposed(by: disposeBag)
        viewModel.activityIndicator.drive(registerButton.rx.isHidden).disposed(by: disposeBag)

        //Errors
        viewModel.errors.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
                switch error {
                case RemoteErrorKey.invalidGrant:
                    self?.form.shake()
                    break
                default: break
                }
            }).disposed(by: disposeBag)

        viewModel.messagesUI.drive(errorLabel.rx.text).disposed(by: disposeBag)
    }
}
