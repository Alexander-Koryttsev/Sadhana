//
//  MainService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/16/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

import Crashlytics

class MainService {
    var user : User?

    init() {
        if let ID = Local.defaults.userID {
            user = Local.service.viewContext.fetch(userFor: ID)
            updateFabricUserData()
        }
    }

    func loadMyEntries() -> Single<[ManagedEntry]> {
        return Remote.service.loadEntries(for: Local.defaults.userID!, lastUpdatedDate: Local.defaults.entriesUpdatedDate ?? Calendar.current.date(byAdding: .month, value: -24, to: Date()))
        .flatMap({ (entries) -> Single<[ManagedEntry]> in
            return Local.service.backgroundContext.rxSave(entries)
        }).do(onNext: { (_) in
            Local.defaults.entriesUpdatedDate = Date()
        })
    }

    func login(_ name:String, password:String) -> Single<ManagedUser> {
        return Remote.service.login(name: name, password: password)
            .concat(Remote.service.loadCurrentUser())
            .flatMap { (user) -> Single<ManagedUser> in
                return Local.service.backgroundContext.rxSave(user:user)
            }
            .do(onNext:{ [unowned self] (user) in
                Local.defaults.userID = user.ID
                self.user = Local.service.viewContext.object(with: user.objectID) as? User
                self.updateFabricUserData()
                Crashlytics.sharedInstance().setUserEmail(name)
                Answers.logLogin(withMethod: nil, success: true, customAttributes: ["Name": user.name, "ID": user.ID])
            }, onError:{ (error) in
                Answers.logLogin(withMethod: nil, success: false, customAttributes: ["Error": error.localizedDescription])
            })
    }
    
    func register(_ registration: Registration) -> Single<ManagedUser> {
        return Remote.service.register(registration)
            .flatMap { _ in
                Answers.logSignUp(withMethod: nil, success: true, customAttributes: ["Name": "\(registration.firstName) \(registration.lastName) \(registration.spiritualName)",
                                                                                    "Country": registration.country,
                                                                                    "City": registration.city,
                                                                                    "Email": registration.email])
                return Main.service.login(registration.email, password: registration.password)
            }
    }

    func updateFabricUserData() {
        if let user = user  {
            Crashlytics.sharedInstance().setUserName(user.name)
            Crashlytics.sharedInstance().setUserIdentifier("\(user.ID)")
        }
    }
}
