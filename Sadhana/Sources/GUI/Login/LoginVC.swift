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

class LoginVC: BaseVC<LoginVM> {
    let loginField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpSubviews()
    }
    
    func setUpSubviews() -> Void {
        setUpLoginField()
        setUpPasswordField()
        setUpLoginButton()
    }
    
    func setUpLoginField() -> Void {
        view.addSubview(loginField)
        
        loginField.placeholder = "Login"
        loginField.borderStyle = .roundedRect
        
        loginField <- [CenterX(0.0).to(view),
                       CenterY(-200.0).to(view),
                       Width(260),
                       Height(44)]
    }
    
    func setUpPasswordField() -> Void {
        view.addSubview(passwordField)
        
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        
        passwordField <- [CenterX(0.0).to(view),
                          CenterY(-100.0).to(view),
                          Width().like(loginField),
                          Height().like(loginField)]
    }
    
    func setUpLoginButton() -> Void {
        view.addSubview(loginButton)
        
        loginButton.setTitle("Sign In", for: .normal)
        
        loginButton <- [CenterX(0.0).to(view),
                          CenterY(0.0).to(view)]
    }
    
    override func bindViewModel() {
        _ = loginField.rx.textRequired.asDriver().drive(viewModel.login)
        _ = passwordField.rx.textRequired.asDriver().drive(viewModel.password)
        _ = loginButton.rx.tap.asDriver().drive(viewModel.tap)
        _ = viewModel.canSignIn.bind(to: loginButton.rx.isEnabled)
    }
}
