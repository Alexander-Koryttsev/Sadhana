//
//  ManagedUser+CoreDataClass.swift
//  
//
//  Created by Alexander Koryttsev on 6/28/17.
//
//


import CoreData

@objc(ManagedUser)
class ManagedUser: ManagedObject, User {
    
    @NSManaged var id: Int32
    var ID: Int32 { get {
        return id
        } set {
            id = newValue
        }
    }
    
    @NSManaged var name: String

    @NSManaged var avatarURLString: String?
    var avatarURL: URL? { get {
        guard let string = avatarURLString else {
            return nil;
        }
        return URL(string: string)
        } set {
            avatarURLString = newValue?.absoluteString
        }
    }
    
    @NSManaged var isPublic : Bool
    @NSManaged var showMore16 : Bool
    
    @NSManaged var wakeUpTimeEnabled : Bool
    @NSManaged var serviceEnabled : Bool
    @NSManaged var exerciseEnabled : Bool
    @NSManaged var lectionsEnabled : Bool
    @NSManaged var bedTimeEnabled : Bool
    
    @NSManaged var entriesUpdatedDate : Date

    @NSManaged var favorites: NSOrderedSet?
    @NSManaged var favoriteBy: ManagedUser?
    
    @discardableResult
    func map(_ user: User) -> Self {
        ID = user.ID
        name = user.name
        avatarURL = user.avatarURL
        
        isPublic = user.isPublic
        showMore16 = user.showMore16
        
        wakeUpTimeEnabled = user.wakeUpTimeEnabled
        serviceEnabled = user.serviceEnabled
        exerciseEnabled = user.exerciseEnabled
        lectionsEnabled = user.lectionsEnabled
        bedTimeEnabled = user.bedTimeEnabled
        
        return self
    }
    
    func containsFavorite(with ID: Int32) -> Bool {
        return favorite(with: ID) != nil
    }
    
    func favorite(with ID: Int32) -> ManagedUser? {
        if let favorites = favorites {
            
            for user in favorites {
                if let user = user as? ManagedUser,
                user.ID == ID {
                    return user
                }
            }
        }
        
        return nil
    }
    
    func add(favorite: UserBriefInfo) {
        guard let context = managedObjectContext else {
            fatalError("User's MO context is nil")
        }
        
        let favoriteUser = context.fetchUser(for: favorite.userID) ?? context.create(ManagedUser.self)
        favoriteUser.ID = favorite.userID
        favoriteUser.avatarURL = favorite.avatarURL
        favoriteUser.name = favorite.userName
        favoriteUser.resetEntriesUpdatedDate()
        add(favorite: favoriteUser)
    }
    
    func add(favorite: ManagedUser) {
        guard let context = managedObjectContext else {
            fatalError("User's MO context is nil")
        }
        addToFavorites(favorite)
        context.saveHanlded()

        _ = Main.service.loadEntries(for: favorite).subscribe()
    }
    
    func removeFromFavorites() {
        guard let context = managedObjectContext else {
            fatalError("User's MO context is nil")
        }
        favoriteBy = nil
        context.saveHanlded()
    }
    
    func resetEntriesUpdatedDate() {
        let defaultDate = Common.shared.calendar.date(byAdding: .year, value: -1, to: Date())!
        if entriesUpdatedDate < defaultDate {
            entriesUpdatedDate = defaultDate
        }
    }
    
    static let entityName = "ManagedUser"
    
    @nonobjc public class func request() -> NSFetchRequest<ManagedUser> {
        return NSFetchRequest<ManagedUser>(entityName: entityName)
    }
}

// MARK: Generated accessors for favorites
extension ManagedUser {
    
    @objc(insertObject:inFavoritesAtIndex:)
    @NSManaged public func insertIntoFavorites(_ value: ManagedUser, at idx: Int)
    
    @objc(removeObjectFromFavoritesAtIndex:)
    @NSManaged public func removeFromFavorites(at idx: Int)
    
    @objc(insertFavorites:atIndexes:)
    @NSManaged public func insertIntoFavorites(_ values: [ManagedUser], at indexes: NSIndexSet)
    
    @objc(removeFavoritesAtIndexes:)
    @NSManaged public func removeFromFavorites(at indexes: NSIndexSet)
    
    @objc(replaceObjectInFavoritesAtIndex:withObject:)
    @NSManaged public func replaceFavorites(at idx: Int, with value: ManagedUser)
    
    @objc(replaceFavoritesAtIndexes:withFavorites:)
    @NSManaged public func replaceFavorites(at indexes: NSIndexSet, with values: [ManagedUser])
    
    @objc(addFavoritesObject:)
    @NSManaged public func addToFavorites(_ value: ManagedUser)
    
    @objc(removeFavoritesObject:)
    @NSManaged public func removeFromFavorites(_ value: ManagedUser)
    
    @objc(addFavorites:)
    @NSManaged public func addToFavorites(_ values: NSOrderedSet)
    
    @objc(removeFavorites:)
    @NSManaged public func removeFromFavorites(_ values: NSOrderedSet)
    
}

