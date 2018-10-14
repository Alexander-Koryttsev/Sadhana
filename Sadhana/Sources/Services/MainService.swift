//
//  MainService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/16/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



import Crashlytics

class MainService {
    var currentUser : ManagedUser?
    private var loadEntriesSharedSignals = [Int32 : Observable<[ManagedEntry]>]()

    init() {
        if let ID = Local.defaults.userID {
            currentUser = Local.service.viewContext.fetchUser(for: ID)
            
            //entriesUpdatedDate migration from Local Defaults to the Core Data
            if let updateDate = Local.defaults.entriesUpdatedDate {
                currentUser!.entriesUpdatedDate  = updateDate
                Local.service.viewContext.saveHandled()
                Local.defaults.entriesUpdatedDate = nil
            }

            if let user = currentUser {
                Local.defaults.userEmail = user.email
            }
        }
    }

    func register(_ registration: Registration) -> Observable<ManagedUser> {
        return Remote.service.register(registration).flatMap{_ -> Observable<ManagedUser> in
            Answers.logSignUp(withMethod: nil, success: true, customAttributes: ["Name": "\(registration.firstName) \(registration.lastName) \(registration.spiritualName)",
                "Country": registration.country,
                "City": registration.city,
                "Email": registration.email])
            return Main.service.login(registration.email, password: registration.password)
        }
    }

    func login(_ name:String, password:String) -> Observable<ManagedUser> {
        return Remote.service.login(name: name, password: password)
            .flatMap{_ in Remote.service.loadCurrentUser()}
            .catchError({ (error) -> Observable<User> in
                if case RemoteError.userNotFound(let userID) = error {
                    return Remote.service.initialize(userID)
                        .flatMap{_ in Remote.service.loadCurrentUser()}
                }
                return Observable<User>.error(error)
            })
            .flatMap{(user) in Local.service.backgroundContext.rxSave(user:user)}
            .do(onNext:{ [unowned self] (user) in
                Local.defaults.userID = user.ID
                Local.defaults.userEmail = name
                Local.defaults.userPassword = password

                self.currentUser = Local.service.viewContext.object(with: user.objectID) as? ManagedUser
                self.currentUser!.resetEntriesUpdatedDate()
                Local.service.viewContext.saveHandled()

                Crashlytics.sharedInstance().setUserName(user.name)
                Crashlytics.sharedInstance().setUserIdentifier(String(user.ID))
                Crashlytics.sharedInstance().setUserEmail(name)
                Answers.logLogin(withMethod: nil, success: true, customAttributes: ["Name": user.name])
            }, onError:{ (error) in
                Answers.logLogin(withMethod: nil, success: false, customAttributes: ["Error": error.localizedDescription])
            })
    }

    func loadMyEntries() -> Observable<[ManagedEntry]> {
        return loadEntries(for: currentUser!)
    }

    func loadEntries(for user:ManagedUser) -> Observable<[ManagedEntry]> {
        let signal : Observable<[ManagedEntry]>

        if let sharedSignal = loadEntriesSharedSignals[user.ID] {
            signal = sharedSignal
        }
        else {
            signal = Remote.service.loadEntries(for: user.userID, lastUpdatedDate: user.entriesUpdatedDate)
                .flatMap{(entries) in Local.service.backgroundContext.rxSave(entries:entries)}
                .do(onNext: { [unowned self] (_) in
                    user.managedObjectContext?.perform {
                        user.entriesUpdatedDate = Date()
                        user.managedObjectContext?.saveHandled()
                    }
                    self.loadEntriesSharedSignals.removeValue(forKey: user.ID)
                }).share(replay: 1, scope: .whileConnected)
            loadEntriesSharedSignals[user.ID] = signal
        }

        return signal
    }

    func sendEntries() -> Observable<Bool> {
        var signals = [Observable<Bool>]()
        let entries = Local.service.viewContext.fetchUnsendedEntries(userID: Local.defaults.userID!)

        for entry in entries {
            let signal = Remote.service.send(entry)
                .observeOn(MainScheduler.instance)
                .map({ (ID) -> Bool in
                    entry.ID = ID
                    entry.dateSynched = Date()
                    Local.service.viewContext.saveHandledRecursive()
                    return true
                })
                .do(onError:{ (error) in
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: entry.json)
                })
            signals.append(signal)
        }

        return Observable.concat(signals)
            .observeOn(MainScheduler.instance)
            .do(onCompleted: {
                NotificationCenter.default.post(name: .local(.entriesDidSend), object: nil)
            })
    }
}
