//
//  LocalService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import CoreData

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
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func newSubViewForegroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func newSubViewBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
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
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}


extension NSManagedObjectContext {
    func fetchUser(for ID:Int32) -> ManagedUser? {
        let request = ManagedUser.request()
        request.predicate = NSPredicate(format: "id == %d", ID)
        return fetchSingle(request)
    }
    
    func fetchEntry(for date:Date, userID:Int32) -> ManagedEntry? {
        let request = ManagedEntry.request()
        request.predicate = NSPredicate(format: "date == %@ AND userID == %d", date.trimmedTime as NSDate, userID)
        return fetchSingle(request)
    }

    func fetchOrCreateEntry(for date:Date, userID:Int32) -> ManagedEntry {
        if let localEntry = fetchEntry(for: date, userID:userID) {
            return localEntry
        }
        else {
            let newEntry = create(ManagedEntry.self)
            newEntry.userID = userID
            newEntry.date = date
            newEntry.month = date.trimmedDayAndTime
            newEntry.dateCreated = Date()
            newEntry.dateUpdated = newEntry.dateCreated
            return newEntry
        }
    }

    func fetchEntries(by month:Date, userID:Int32) -> [ManagedEntry] {
        let request = ManagedEntry.request()
        request.predicate = NSPredicate(format: "month == %@ AND userID == %d", month.trimmedDayAndTime as NSDate, userID)
        return fetchHandled(request)
    }

    private func fetchHandled<T>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try fetch(request)
        }
        catch {
            fatalError("Can't fetch: \(error)")
        }
    }
    
    private func fetchSingle<T>(_ request: NSFetchRequest<T>) -> T? {
        request.fetchLimit = 1
        
        do {
            return try fetch(request).first
        }
        catch {
            log(error)
        }
        
        return nil
    }

    func saveHandledRecursive() {
        saveHandled()

        if self.parent != nil {
            if Thread.isMainThread,
                self.parent?.concurrencyType == .mainQueueConcurrencyType {
                self.parent?.saveHandledRecursive()
            }
            else {
                self.parent?.performAndWait {
                    self.parent?.saveHandledRecursive()
                }
            }
        }
    }

    func saveHandled() {
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
                    #if DEBUG
                    fatalError("Failure to fetch data: \(error)")
                    #endif
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
        return Completable.create { [unowned self] (observer) -> Disposable in
            self.perform {
                do {
                    if self.persistentStoreCoordinator != nil && self.persistentStoreCoordinator!.persistentStores.count == 0 {
                        log("trying save without persistent stores")
                        //TODO: create pretty error
                        observer(.error(GeneralError.error))
                        return
                    }
                    try self.save()
                    if let parent = self.parent {
                        _ = parent.rxSave().subscribe(observer)
                    }
                    else {
                        observer(.completed)
                    }
                } catch {
                    observer(.error(error))

                    #if DEBUG
                        fatalError("Failure to save context: \(error)")
                    #endif
                }
            }

            return Disposables.create {}
        }
    }

    func rxSave(user:User) -> Single<ManagedUser> {
        let request = ManagedUser.request()
        request.predicate = NSPredicate(format: "id = %d", user.ID)
        request.fetchLimit = 1
        return rxFetch(request).map { [unowned self] (localUsers) -> ManagedUser in
            var localUser : ManagedUser? = nil

            self.performAndWait {
                localUser = localUsers.count > 0 ? localUsers.first! : self.create(ManagedUser.self)
                localUser!.map(user:user)
            }

            return localUser!
            }.concat(rxSave())
    }

    func rxSave(_ entries:[Entry]) -> Single<[ManagedEntry]> {
        let request = ManagedEntry.request()
        let IDs = entries.flatMap { (entry) -> Int32 in
            return entry.ID!
        }
        request.predicate = NSPredicate(format: "id IN %@", IDs)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return self.rxFetch(request).map { [unowned self] (localEntries) -> [ManagedEntry] in
            var remoteEntries = entries.sorted(by: { (entry1, entry2) -> Bool in
                return entry1.ID! <  entry2.ID!
            })
            var updatedLocalEntries = [ManagedEntry]()

            self.performAndWait {
                var localEntriesMutable = localEntries
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

                    let newEntry = self.create(ManagedEntry.self)
                    newEntry.map(remoteEntry)
                    updatedLocalEntries.append(newEntry)
                    remoteEntries.removeFirst()
                }
            }

            return updatedLocalEntries
        }.concat(rxSave())
    }
}

