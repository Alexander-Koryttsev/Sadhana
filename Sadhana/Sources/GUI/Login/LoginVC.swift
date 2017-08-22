//
//  LoginVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
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

    override func viewDidLoad() {
        view.backgroundColor = .white
        setUpSubviews()
        buildConstraints()
        animateForm()
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { get { return UIStatusBarStyle.lightContent } }

    func setUpSubviews() {
        setUpBackground()
        setUpFormAndLogo()
        setUpActivityIndicator()
        setUpErrorLabel()
    }

    func setUpBackground() {
        let gradient = CircleGradientView()
        view.addSubview(gradient)
        gradient <- Edges()

        let prabhupada = UIImageView(screenSized:"prabhupada")
        prabhupada.contentMode = .center
        view.addSubview(prabhupada)
        prabhupada <- [
            Left(),
            Top(),
            Right()
        ]

        let sevaLogo = UIImageView(screenSized:"v-seva-logo")
        view.addSubview(sevaLogo)
        sevaLogo <- [
            Right(screenWidthSecific(w320: 12, w375: 14, w414: 21)),
            Bottom(screenWidthSecific(w320: 12, w375: 14, w414: 21))
        ]

        view.addSubview(darkBackground)
        darkBackground.backgroundColor = .black
        darkBackground.alpha = 0
        darkBackground <- Edges()
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
        form <- Edges()

        setUpLoginField()
        setUpPasswordField()
        setUpLoginButton()
        setUpLogo()
    }

    func setUpLoginField(){
        form.addSubview(loginField)
        loginField.placeholder = "login".localized
        loginField.borderStyle = .none
        loginField.textAlignment = .center
        loginField.font = UIFont.sdTextStyle3Font()
        loginField.keyboardAppearance = .dark
        loginField.autocorrectionType = .no
        loginField.keyboardType = .emailAddress
        loginField.returnKeyType = .next
        loginField.delegate = self
        loginField <- [
            Top(),
            Left(8),
            Right(8),
            Height(44)
        ]
    }
    
    func setUpPasswordField() {
        let separator = UIView()
        form.addSubview(separator)
        separator.backgroundColor = .sdPaleGrey
        separator <- [
            Top().to(loginField),
            Left().to(loginField, .left),
            Right().to(loginField, .right),
            Height(1),
        ]

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
        passwordField <- [
            Top().to(separator),
            Left().to(loginField, .left),
            Right().to(loginField, .right),
            Height().like(loginField)
        ]
    }

    func setUpLoginButton() {
        form.addSubview(loginButton)
        loginButton.setTitle("signIn".localized, for: .normal)
        loginButton.titleLabel?.font = UIFont.sdTextStyle2Font()
        loginButton <- [
            Top().to(passwordField),
            Left(),
            Right(),
            Height(59),
            Bottom(0)
        ]

        loginButton.addSubview(arrow)
        arrow <- [
            CenterY().to(loginButton.titleLabel!),
            Left(10).to(loginButton.titleLabel!, .right)
        ]
    }

    func setUpActivityIndicator() {
        form.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator <- [
            CenterX().to(loginButton),
            CenterY().to(loginButton)
        ]
    }

    func setUpErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.numberOfLines = 0
        errorLabel.textColor = UIColor.white
        errorLabel.textAlignment = .center
        errorLabel.text = ""
        errorLabel <- [
            Top(12).to(form),
            CenterX(),
            Width(280)
        ]
    }

    func buildConstraints() {
        formArea <- [
            Top(),
            Left(),
            Right(),
            Bottom(0)
        ]

        logo <- Center().with(.high)

        titleLabel <- [
            Top().to(logo),
            CenterX()
        ]

        formContainer <- [
            Top(22).to(titleLabel),
            Width(280),
            CenterX()
        ]
    }

    func animateForm() {
        formContainer.alpha = 0
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.formContainer <- Top(-5).to(self.formArea, .centerY)
            self.titleLabel <- Bottom(22).to(self.formContainer)

            UIView.animate(withDuration: 1.5, animations: {
                self.formArea.layoutIfNeeded()
                self.formContainer.alpha = 1
            })
        })
    }

    func keyboardWillChange(notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboarFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let shown = keyboarFrame.origin.y < UIScreen.main.bounds.size.height

        UIView.animate(withDuration: 0.3) {
            self.formArea <- Bottom(shown ? keyboarFrame.size.height : 0)
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
            viewModel.tap.onNext()
        }
        return true
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        loginField.text = viewModel.login.value
        loginField.rx.textRequired.asDriver().distinctUntilChanged()
            .do(onNext:{ [weak self] _ in self?.errorLabel.text = nil})
            .drive(viewModel.login).disposed(by: disposeBag)

        passwordField.text = viewModel.password.value
        passwordField.rx.textRequired.asDriver().distinctUntilChanged()
            .do(onNext:{ [weak self] _ in self?.errorLabel.text = nil})
            .drive(viewModel.password).disposed(by: disposeBag)

        loginButton.rx.tap.asDriver()
            .do(onNext:{ [weak self] () in self?.errorLabel.text = nil})
            .drive(viewModel.tap).disposed(by: disposeBag)

        viewModel.canSignIn.drive(loginButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.activityIndicator.drive(activityIndicator.rx.isAnimating).disposed(by: disposeBag)
        viewModel.activityIndicator.drive(arrow.rx.isHidden).disposed(by: disposeBag)

        let enabled = viewModel.activityIndicator
            .map({ (animating) -> Bool in  return !animating })

        enabled.drive(loginField.rx.isEnabled).disposed(by: disposeBag)
        enabled.drive(passwordField.rx.isEnabled).disposed(by: disposeBag)
        enabled.map({ (flag) -> CGFloat in
            return flag ? 1.0 : 0.0
        }).drive(loginButton.titleLabel!.rx.alpha).disposed(by: disposeBag)

        viewModel.errorMessagesUI
            .drive(errorLabel.rx.text).disposed(by: disposeBag)

        viewModel.errors.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (error) in
            switch error {
                case RemoteError.invalidRequest(let type, _):
                    if type == InvalidRequestType.invalidGrant {
                        self?.form.shake()
                    }
                    break
                default: break
                }
            }).disposed(by: disposeBag)

        viewModel.messagesUI.drive(errorLabel.rx.text).disposed(by: disposeBag)

        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.loginField.resignFirstResponder()
                self?.passwordField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
}
