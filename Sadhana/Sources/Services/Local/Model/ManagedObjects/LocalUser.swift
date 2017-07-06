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
    var ID: Int { get {
        return id
        } set {
            id = newValue
        }
    }
    
    @NSManaged var name: String
    
    var avatarURL: URL? { get {
        guard let string = avatarURLString else {
            return nil;
        }
        return URL(string: string)
        } set {
            avatarURLString = newValue?.absoluteString
        }
    }
    
    @NSManaged var id: Int
    @NSManaged var avatarURLString: String?
    
    func json() -> JSON {
        return [
            "userid" : ID,
            "user_name": name,
            "avatar_url": avatarURLString ?? ""
        ]
    }
    
    func map(_ user: User) -> Void {
        ID = user.ID
        name = user.name
        avatarURL = user.avatarURL
    }
}
