//
//  MainService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/16/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift
import Crashlytics

class MainService {
    static let shared = MainService()

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
            .do(onNext:{ (user) in
                Local.defaults.userID = user.ID
                Answers.logLogin(withMethod: nil, success: true, customAttributes: ["Name": user.name, "ID": user.ID])
            }, onError:{ (error) in
                Answers.logLogin(withMethod: nil, success: false, customAttributes: ["Error": error.localizedDescription])
            })
    }
}
