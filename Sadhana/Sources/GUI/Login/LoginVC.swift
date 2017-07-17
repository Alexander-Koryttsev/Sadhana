//
//  LoginVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import EasyPeasy

class LoginVC: BaseVC<LoginVM>, UITextFieldDelegate {
    let darkBackground = UIView()
    let formArea = UIView()
    let titleLabel = UILabel()
    let formContainer = UIView()
    let form = UIView()
    let loginField = UITextField()
    let passwordField = UITextField()
    let errorLabel = UILabel()
    let loginButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpSubviews()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { get {
        return UIStatusBarStyle.lightContent
        }
    }
    
    func setUpSubviews() {
        setUpBackground()
        setUpFormAndLogo()
    }

    func setUpBackground() {
        let gradient = CircleGradientView()
        view.addSubview(gradient)

        gradient <- Edges()

        let prabhupada = UIImageView(image:UIImage(named:"prabhupada"))
        prabhupada.contentMode = .scaleAspectFill
        view.addSubview(prabhupada)

        prabhupada <- [
            Left(),
            Top(),
            Right()
        ]

        let sevaLogo = UIImageView(image:UIImage(named:"v-seva-logo"))
        view.addSubview(sevaLogo)

        sevaLogo <- [
            Right(12),
            Bottom(12)
        ]

        darkBackground.backgroundColor = UIColor.black
        darkBackground.alpha = 0
        view.addSubview(darkBackground)

        darkBackground <- Edges()
    }

    func setUpFormAndLogo() {
        formArea.backgroundColor = UIColor.clear
        view.addSubview(formArea)
        formArea <- [
            Top(),
            Left(),
            Right(),
            Bottom(0)
        ]

        formContainer.layer.shadowOpacity = 1
        formContainer.layer.shadowRadius = 5
        formContainer.layer.shadowColor = UIColor.sdMudBrown12.cgColor
        formContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        formArea.addSubview(formContainer)

        formContainer <- [
            Top(-5).to(formArea, .centerY),
            Width(280),
            CenterX()
        ]

        form.backgroundColor = UIColor.white
        form.clipsToBounds = true
        form.layer.cornerRadius = 5

        formContainer.addSubview(form)

        form <- Edges()

        setUpLoginField()
        setUpPasswordField()
        //setUpErrorLabel()
        setUpLoginButton()
        setUpLogo()
    }

    func setUpLoginField(){
        form.addSubview(loginField)
        
        loginField.placeholder = "Логин"
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
        separator.backgroundColor = UIColor.sdPaleGrey
        form.addSubview(separator)

        separator <- [
            Top().to(loginField),
            Left().to(loginField, .left),
            Right().to(loginField, .right),
            Height(1),
        ]

        form.addSubview(passwordField)
        
        passwordField.placeholder = "Пароль"
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

    func setUpErrorLabel() {
        view.addSubview(errorLabel)

        errorLabel.text = ""

        errorLabel <- [CenterX(),
                        CenterY(-50)]
    }

    func setUpLoginButton() {
        form.addSubview(loginButton)
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.backgroundColor = UIColor.sdTangerine
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.sdTextStyle2Font()
        
        loginButton <- [
            Top().to(passwordField),
            Left(),
            Right(),
            Height(59),
            Bottom(0)
        ]
    }

    func setUpLogo() {
        titleLabel.text = "Садхана"
        titleLabel.font = UIFont.sdTextStyle1Font()
        titleLabel.textColor = UIColor.white

        formArea.addSubview(titleLabel)

        titleLabel <- [
            Bottom(22).to(formContainer),
            CenterX()
        ]

        let logo = UIImageView(image:UIImage(named:"icon"))

        formArea.addSubview(logo)

        logo <- [
            CenterX(),
            Bottom().to(titleLabel)
        ]
    }

    func keyboardWillChange(notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboarFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

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
        _ = loginField.rx.textRequired.asDriver().drive(viewModel.login)
        _ = passwordField.rx.textRequired.asDriver().drive(viewModel.password)
        _ = loginButton.rx.tap.asDriver()
            .do(onNext:{ [weak self] () in self?.errorLabel.text = nil})
            .drive(viewModel.tap)
        _ = viewModel.canSignIn.drive(loginButton.rx.isEnabled)
        _ = viewModel.errorMessagesUI.drive(errorLabel.rx.text)


        _ = viewModel.errorMessagesUI.asObservable().subscribe(onNext: { (message) in
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.6
            animation.values = [-20.0, 20.0, -15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
            self.form.layer.add(animation, forKey: "shake")
        })
    }
}
