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
    var viewContext : NSManagedObjectContext {
        get {
            return persistentContainer.viewContext;
        }
    }
    
    private var persistentContainer: NSPersistentContainer
    var backgroundContext: NSManagedObjectContext
    
    init(completionClosure: @escaping () -> ()) {
        //TODO: clear data base on migration
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func newSubViewForegroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext;
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
                    log(error)
                }
            }
        }
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
        backgroundContext = persistentContainer.newBackgroundContext()
    }
}


extension NSManagedObjectContext {
    
    func fetchUser() -> ManagedUser? {
        return fetchSingle(ManagedUser.request())
    }
    
    func fetch(userFor ID:Int32) -> ManagedUser? {
        let request = ManagedUser.request()
        request.predicate = NSPredicate(format: "id = %d", ID)
        return fetchSingle(request)
    }
    
    func fetch(entryFor date:Date) -> ManagedEntry? {
        let request = ManagedEntry.request()
        //TODO: add user ID
        //TODO: debug
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        return fetchSingle(request)
    }

    func fetch(entriesFrom month:Date) -> [ManagedEntry] {
        let request = ManagedEntry.request()
        request.predicate = NSPredicate(format: "month == %@", month as NSDate)
        return fetchHandled(request)
    }

    private func fetchHandled<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try fetch(request)
        }
        catch {
            fatalError("Can't fetch: \(error)")
        }
    }
    
    private func fetchSingle<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) -> T? {
        request.fetchLimit = 1
        
        do {
            return try fetch(request).first
        }
        catch {
            log(error)
        }
        
        return nil
    }

    func saveRecursive() {
        saveHanlded()

        if self.parent != nil {
            if Thread.isMainThread,
                self.parent?.concurrencyType == .mainQueueConcurrencyType {
                self.parent?.saveRecursive()
            }
            else {
                self.parent?.performAndWait {
                    self.parent?.saveRecursive()
                }
            }
        }
    }

    func saveHanlded() {
        if self.concurrencyType == .mainQueueConcurrencyType,
            !Thread.isMainThread {
            self.performAndWait {
                self.saveHandledInternal()
            }
        }
        else {
           saveHandledInternal()
        }
    }

    private func saveHandledInternal() {
        do {
            try self.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func create<T:NSManagedObject>(_ type: T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(T.self), into: self) as! T
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

    func rxSave() -> Completable {
        return Completable.create { [weak self] (observer) -> Disposable in
            self?.perform {
                do {
                    if self?.persistentStoreCoordinator != nil && self!.persistentStoreCoordinator!.persistentStores.count == 0 {
                        log("trying save without persistent stores")
                        //TODO: create pretty error
                        observer(.error(GeneralError.error))
                        return
                    }
                    try self?.save()
                    if let parent = self?.parent {
                        _ = parent.rxSave().subscribe(observer)
                    }
                    else {
                        observer(.completed)
                    }
                } catch {
                    observer(.error(error))
                    //TODO: Remove on release
                    fatalError("Failure to save context: \(error)")
                }
            }

            return Disposables.create {}
        }
    }

    func rxSave(user:User) -> Single<ManagedUser> {
        let request = ManagedUser.request()
        request.predicate = NSPredicate(format: "id = %d", user.ID)
        request.fetchLimit = 1
        return rxFetch(request).map { [weak self] (localUsers) -> ManagedUser in
            let localUser = localUsers.count > 0 ? localUsers.first! : self!.create(ManagedUser.self)
            return localUser.map(user)
            }.concat(rxSave())
    }

    func rxSave(_ entries:[Entry]) -> Single<[ManagedEntry]> {
        //TODO: make thread-safe
        let request = ManagedEntry.request()
        let IDs = entries.flatMap { (entry) -> Int32 in
            return entry.ID!
        }
        request.predicate = NSPredicate(format: "id IN %@", IDs)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return self.rxFetch(request).map { [weak self] (localEntries) -> [ManagedEntry] in
            //TODO: Check is context's queue
            var remoteEntries = entries.sorted(by: { (entry1, entry2) -> Bool in
                return entry1.ID! <  entry2.ID!
            })
            var localEntriesMutable = localEntries
            var updatedLocalEntries = [ManagedEntry]()

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

                let newEntry = self!.create(ManagedEntry.self)
                newEntry.map(remoteEntry)
                updatedLocalEntries.append(newEntry)
                remoteEntries.removeFirst()
            }

            return updatedLocalEntries
        }.concat(rxSave())
    }
}

