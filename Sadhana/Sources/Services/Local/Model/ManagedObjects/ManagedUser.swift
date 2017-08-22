//
//  ManagedUser+CoreDataClass.swift
//  
//
//  Created by Alexander Koryttsev on 6/28/17.
//
//

import Foundation
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
    
    static let entityName = "ManagedUser"
    
    @nonobjc public class func request() -> NSFetchRequest<ManagedUser> {
        return NSFetchRequest<ManagedUser>(entityName: entityName)
    }
}
