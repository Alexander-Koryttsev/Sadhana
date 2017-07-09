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
    
    private func perform<T:NSManagedObject>(_ request:NSFetchRequest<T>) -> Single<[T]> {
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
    
    private func performSingle<T:NSManagedObject>(_ request:NSFetchRequest<T>) -> Single<T?> {
        request.fetchLimit = 1;
        return perform(request).map({ (objects) -> T? in
            return objects.first
        })
    }
    
    func create<T:NSManagedObject>(_ type: T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(T.self), into: self.backgroundContext) as! T
    }
    
    func save(_ user:User) -> Single<LocalUser> {
        let request = LocalUser.request()
        request.predicate = NSPredicate(format: "id = %d", user.ID)
        request.fetchLimit = 1
        return perform(request).map { [weak self] (localUsers) -> LocalUser in
            let localUser = localUsers.count > 0 ? localUsers.first! : self!.create(LocalUser.self)
            return localUser.map(user)
        }.concat(self.saveContext())
    }
    
    func save(_ entries:[SadhanaEntry]) -> Single<[LocalSadhanaEntry]> {
        let request = LocalSadhanaEntry.request()
        let IDs = entries.flatMap { (entry) -> Int32 in
            return entry.ID!
        }
        request.predicate = NSPredicate(format: "id IN %@", IDs)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return self.perform(request).map { [weak self] (localEntries) -> [LocalSadhanaEntry] in
            var remoteEntries = entries.sorted(by: { (entry1, entry2) -> Bool in
                //TODO: check IDs sorting
                return entry1.ID! <  entry2.ID!
            })
            var localEntriesMutable = localEntries
            var updatedLocalEntries = [LocalSadhanaEntry]()
            
            while remoteEntries.count > 0 {
                let remoteEntry = remoteEntries.first!
                let remoteEntryID = remoteEntry.ID!
                if localEntriesMutable.count > 0 {
                    let localEntry = localEntriesMutable.first!
                    let localEntryID = localEntry.ID!
                    switch localEntryID {
                        case remoteEntryID:
                            localEntry.map(remoteEntry)
                            updatedLocalEntries.append(localEntry)
                            localEntriesMutable.removeFirst()
                            remoteEntries.removeFirst()
                            continue
                        case 0..<remoteEntryID:
                            localEntriesMutable.removeFirst()
                            continue
                        default: break
                    }
                }
              
                let newEntry = self!.create(LocalSadhanaEntry.self)
                newEntry.map(remoteEntry)
                updatedLocalEntries.append(newEntry)
                remoteEntries.removeFirst()
            }
            
            return updatedLocalEntries
        }.concat(self.saveContext())
    }
    
    func fetchUser() -> Single<LocalUser?> {
        return performSingle(LocalUser.request())
    }
    
    func fetchSadhanaEntry() -> Single<LocalSadhanaEntry?> {
        return performSingle(LocalSadhanaEntry.request())
    }
}

