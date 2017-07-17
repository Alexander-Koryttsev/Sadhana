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
    var viewContext : NSManagedObjectContext {
        get {
            return persistentContainer.viewContext;
        }
    }
    
    private let persistentContainer: NSPersistentContainer
    var backgroundContext: NSManagedObjectContext
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func newForegroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator;
        return context;
    }

    func newSubViewBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext;
        return context;
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext();
    }

    func dropDatabase(completionClosure: @escaping () -> ()) {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores
        for store in stores {
            if let urlLet = store.url {
                do {
                try persistentContainer.persistentStoreCoordinator.remove(store)
                try FileManager.default.removeItem(at: urlLet)
                }
                catch {
                    print(error)
                }
            }
        }
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
    }
}


extension NSManagedObjectContext {
    func save(user:User) -> Single<LocalUser> {
        let request = LocalUser.request()
        request.predicate = NSPredicate(format: "id = %d", user.ID)
        request.fetchLimit = 1
        return rxFetch(request).map { [weak self] (localUsers) -> LocalUser in
            let localUser = localUsers.count > 0 ? localUsers.first! : self!.create(LocalUser.self)
            return localUser.map(user)
        }.concat(rxSave())
    }
    
    func save(_ entries:[SadhanaEntry]) -> Single<[LocalSadhanaEntry]> {
        //TODO: make thread-safe
        let request = LocalSadhanaEntry.request()
        let IDs = entries.flatMap { (entry) -> Int32 in
            return entry.ID!
        }
        request.predicate = NSPredicate(format: "id IN %@", IDs)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return self.rxFetch(request).map { [weak self] (localEntries) -> [LocalSadhanaEntry] in
            var remoteEntries = entries.sorted(by: { (entry1, entry2) -> Bool in
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
            }.concat(rxSave())
    }
    
    func fetchUser() -> LocalUser? {
        return fetchSingle(LocalUser.request())
    }
    
    func fetchUser(ID:Int32) -> LocalUser? {
        let request = LocalUser.request()
        request.predicate = NSPredicate(format: "id = %d", ID)
        return fetchSingle(request)
    }
    
    func fetchSadhanaEntry() -> Single<LocalSadhanaEntry?> {
        return rxFetchSingle(LocalSadhanaEntry.request())
    }


    func mySadhanaEntriesFRC() -> NSFetchedResultsController<LocalSadhanaEntry> {
        let request = LocalSadhanaEntry.request()
        request.sortDescriptors = [NSSortDescriptor(key:"date", ascending:false)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self, sectionNameKeyPath: "month", cacheName: nil)
    }

    
    func fetchSingle<T>(_ request: NSFetchRequest<T>) -> T? where T : NSFetchRequestResult {
        request.fetchLimit = 1
        
        do {
            return try fetch(request).first
        }
        catch {
            print(error)
        }
        
        return nil
    }
    
    func rxSave() -> Completable {
        return Completable.create { [weak self] (observer) -> Disposable in
            self?.perform {
                do {
                    try self?.save()
                    if let parent = self?.parent {
                        _ = parent.rxSave().subscribe(observer)
                    }
                    else {
                        observer(.completed)
                    }
                } catch {
                    observer(.error(error))
                    fatalError("Failure to save context: \(error)")
                }
            }
            
            return Disposables.create {}
        }
    }
    
    private func rxFetch<T:NSManagedObject>(_ request:NSFetchRequest<T>) -> Single<[T]> {
        return Single<[T]>.create { [weak self] (observer) -> Disposable in
            self?.perform {
                do {
                    if let result = try self?.fetch(request) {
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
    
    private func rxFetchSingle<T:NSManagedObject>(_ request:NSFetchRequest<T>) -> Single<T?> {
        request.fetchLimit = 1;
        return rxFetch(request).map({ (objects) -> T? in
            return objects.first
        })
    }
    
    func create<T:NSManagedObject>(_ type: T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(T.self), into: self) as! T
    }

}

