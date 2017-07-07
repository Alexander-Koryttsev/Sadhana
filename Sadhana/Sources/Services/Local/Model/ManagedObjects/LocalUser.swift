//
//  LocalUser+CoreDataClass.swift
//  
//
//  Created by Alexander Koryttsev on 6/28/17.
//
//

import Foundation
import CoreData

@objc(LocalUser)
class LocalUser: NSManagedObject, User, JSONConvertible {
    
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
    
    func json() -> JSON {
        return [
            "userid" : ID,
            "user_name": name,
            "avatar_url": avatarURLString ?? "",
            
            "cfg_public": isPublic,
            "cfg_showmoresixteen": showMore16,
            
            "opt_wake": wakeUpTimeEnabled,
            "opt_service": serviceEnabled,
            "opt_exercise": exerciseEnabled,
            "opt_lections": lectionsEnabled,
            "opt_sleep": bedTimeEnabled,
        ]
    }
    
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
    
    class func entityName() -> String {
        return "LocalUser"
    }
    
    @nonobjc public class func request() -> NSFetchRequest<LocalUser> {
        return NSFetchRequest<LocalUser>(entityName: self.entityName())
    }
}

