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
      /*  let loadUser = RemoteService.shared.loadCurrentUser()
        _ = loadUser.debug().subscribe()*/
        
        /*
        let handleErrorOnLoadUser = loadUser.asObservable().catchError { (error) -> Observable<User> in
            let returningError = Observable<User>.error(error)
            guard let remoteError = error as? RemoteError else { return returningError }
            
            switch remoteError {
                case .notLoggedIn: return loadUser.asObservable().after(RemoteService.shared.login(name: "sanio91@ya.ru", password: "Ale248Vai"))
                default: return returningError
            }
        }
        
        let saveUser = handleErrorOnLoadUser.flatMap { (user) -> Single<LocalUser> in
            return LocalService.shared.save(user)
        }
        */
    /*    let fetchUser = LocalService.shared.fetchUser()
        _ = fetchUser.subscribe(onSuccess: { (user) in
            if user != nil {
                _ = RemoteService.shared.send(user!).debug().subscribe()
            }
        })*/
        
        let fetchSadhana = LocalService.shared.fetchSadhanaEntry()
        _ = fetchSadhana.subscribe(onSuccess: { (sadhanaEntry) in
            if sadhanaEntry != nil {
                _ = RemoteService.shared.send(sadhanaEntry!).subscribe(onSuccess: { (entryID) in
                    sadhanaEntry!.ID = entryID
                    print(entryID)
                    LocalService.shared.saveContext().subscribe()
                })
            }
        })
        
        
       /* let loadSadhana = RemoteService.shared.loadSadhanaEntries(userID: 398, year: 2017, month: 2).debug().subscribe()*/
       /*
        let loadSadhana = saveUser.flatMap { (user) -> Single<[SadhanaEntry]> in
            return RemoteService.shared.loadSadhanaEntries(userID: user.ID, year: 2017, month: 2);
        }
        
        let saveSadhana = loadSadhana.flatMap { (entries) -> Single<[LocalSadhanaEntry]> in
            return LocalService.shared.save(entries)
        }
        
        _ = saveSadhana.debug().subscribe()*/
    }
}


