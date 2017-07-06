//
//  FirstViewController.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 5/15/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadUser = RemoteService.shared.loadCurrentUser()
        let loadUserWithErrorHandling = loadUser.asObservable().catchError { (error) -> Observable<User> in
            let returningError = Observable<User>.error(error)
            guard let remoteError = error as? RemoteError else { return returningError }
            
            switch remoteError {
                case .notLoggedIn: return loadUser.asObservable().after(RemoteService.shared.login(name: "sanio91@ya.ru", password: "Ale248Vai"))
                default: return returningError
            }
            
        }
        let sendUser = loadUserWithErrorHandling.do(onNext: { (user) in
           // RemoteService.shared.send(user: user as! MutableUser)
        })
        _ = sendUser.debug().subscribe()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


