//
//  LocalService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

enum LocalError : Error {
    case noData
}

class LocalService: NSObject {
    
    static let shared = LocalService {}
    
    private let persistentContainer: NSPersistentContainer
    private var backgroundContext: NSManagedObjectContext
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            else {
                
            }
            completionClosure()
        }
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func saveContext() -> Completable {
        return Completable.create { [weak self] (observer) -> Disposable in
            self?.backgroundContext.perform {
                do {
                    try self?.backgroundContext.save()
                    observer(.completed)
                } catch {
                    observer(.error(error))
                    fatalError("Failure to save context: \(error)")
                }
            }
            
            return Disposables.create {}
        }
    }
    
    func perform<T:NSManagedObject>(_ request:NSFetchRequest<T>) -> Single<[T]> {
        return Single<[T]>.create { [weak self] (observer) -> Disposable in 
            self?.backgroundContext.perform {
                do {
                    if let result = try self?.backgroundContext.fetch(request) {
                        observer(.success(result))
                    }
                    else {
                        observer(.error(LocalError.noData))
                    }
                } catch {
                    observer(.error(error))
                    fatalError("Failure to fetch data: \(error)")
                }
            }
            return Disposables.create {}
        }
    }
    
    func save(_ user:User) -> Single<LocalUser> {
        let request = LocalUser.request()
        request.predicate = NSPredicate(format: "id = %d", user.ID)  
        request.fetchLimit = 1
        return perform(request).map { [weak self] (localUsers) -> LocalUser in
            let localUser:LocalUser
            if (localUsers.count > 0) {
                localUser = localUsers.first!
            }
            else {
                if let selfWeak = self {
                    localUser = NSEntityDescription.insertNewObject(forEntityName: LocalUser.entityName(), into: selfWeak.backgroundContext) as! LocalUser
                }
                else {
                    throw LocalError.noData
                }
            }
            
            return localUser.map(user)
        }.do(onCompleted: {
            do {
                try self.backgroundContext.save()
                print("saved");
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        })
    }
}

