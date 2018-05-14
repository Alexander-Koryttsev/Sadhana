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
    private var loadEntriesSharedSignals = [Int32 : Single<[ManagedEntry]>]()

    init() {
        if let ID = Local.defaults.userID {
            currentUser = Local.service.viewContext.fetchUser(for: ID)
            updateFabricUserData()
            
            //entriesUpdatedDate migration from Local Defaults to the Core Data
            if let updateDate = Local.defaults.entriesUpdatedDate {
                currentUser!.entriesUpdatedDate  = updateDate
                Local.service.viewContext.saveHandled()
                Local.defaults.entriesUpdatedDate = nil
            }
        }
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

    func login(_ name:String, password:String) -> Single<ManagedUser> {
        return Remote.service.login(name: name, password: password)
            .concat(Remote.service.loadCurrentUser())
            .catchError({ (error) -> PrimitiveSequence<SingleTrait, User> in

                if case RemoteError.invalidRequest(type: .userNotFound, let description) = error {
                    if let stringID = description.components(separatedBy: " ").last {
                           if let ID = Int32(stringID) {
                            return Remote.service.loadCurrentUser().after(Remote.service.initialize(ID))
                        }
                    }
                }

                return Single<User>.error(error)
            })
            .flatMap { (user) -> Single<ManagedUser> in
                return Local.service.backgroundContext.rxSave(user:user)
            }
            .do(onSuccess:{ [unowned self] (user) in
                Local.defaults.userID = user.ID
                self.currentUser = Local.service.viewContext.object(with: user.objectID) as? ManagedUser
                self.currentUser!.resetEntriesUpdatedDate()
                Local.service.viewContext.saveHandled()
                self.updateFabricUserData()
                Crashlytics.sharedInstance().setUserEmail(name)
                Answers.logLogin(withMethod: nil, success: true, customAttributes: ["Name": user.name])
            }, onError:{ (error) in
                Answers.logLogin(withMethod: nil, success: false, customAttributes: ["Error": error.localizedDescription])
            })
    }

    func updateFabricUserData() {
        if let user = currentUser  {
            Crashlytics.sharedInstance().setUserName(user.name)
            Crashlytics.sharedInstance().setUserIdentifier("\(user.ID)")
        }
    }

    func loadMyEntries() -> Single<[ManagedEntry]> {
        return loadEntries(for: currentUser!)
    }

    func loadEntries(for user:ManagedUser) -> Single<[ManagedEntry]> {
        let signal : Single<[ManagedEntry]>

        if let sharedSignal = loadEntriesSharedSignals[user.ID] {
            signal = sharedSignal
        }
        else {
            signal = Remote.service.loadEntries(for: user.userID, lastUpdatedDate: user.entriesUpdatedDate)
                .flatMap({ (entries) -> Single<[ManagedEntry]> in
                    return Local.service.backgroundContext.rxSave(entries)
                }).do(onSuccess: { [unowned self] (_) in
                    user.managedObjectContext?.perform {
                        user.entriesUpdatedDate = Date()
                        user.managedObjectContext?.saveHandled()
                    }
                    self.loadEntriesSharedSignals.removeValue(forKey: user.ID)
                }).asObservable().share(replay: 1, scope: .whileConnected).asSingle()
            loadEntriesSharedSignals[user.ID] = signal
        }

        return signal
    }

    func sendEntries() -> Observable<Bool> {
        var signals = [Observable<Bool>]()
        let entries = Local.service.viewContext.fetchUnsendedEntries(userID: Local.defaults.userID!)

        for entry in entries {
            let signal = Remote.service.send(entry)
                .subscribeOn(MainScheduler.instance)
                .observeOn(MainScheduler.instance)
                .do(onSuccess: { (ID) in
                    entry.ID = ID
                    entry.dateSynched = Date()
                    Local.service.viewContext.saveHandledRecursive()
                    }, onError:{ (error) in
                        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: entry.json)
                })
                .asBoolObservable()
            signals.append(signal)
        }

        return Observable.merge(signals)
            .observeOn(MainScheduler.instance)
            .do(onCompleted: {
                NotificationCenter.default.post(name: .local(.entriesDidSend), object: nil)
            })
    }
}
