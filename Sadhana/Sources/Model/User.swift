//
//  User.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


protocol User: UserBriefInfo, JSONConvertible {
    var ID : Int32 { get }
    var name : String { get }
    var avatarURL : URL? { get }
    
    var isPublic : Bool { get }
    var showMore16 : Bool { get }
    
    var wakeUpTimeEnabled : Bool { get }
    var serviceEnabled : Bool { get }
    var exerciseEnabled : Bool { get }
    var lectionsEnabled : Bool { get }
    var bedTimeEnabled : Bool { get }
}
protocol UserBriefInfo {
    var userID : Int32 { get }
    var userName : String { get }
    var avatarURL : URL? { get }
}

extension User { // UserBriefInfo
    var userID : Int32 {
        return ID
    }
    var userName : String {
        return name
    }
}

extension User { // JSONConvertible
    var json : JSON {
        get {
            return ["userid": ID,
                    "user_name": name,
                    "avatar_url": avatarURL?.absoluteString ?? "",

                    "cfg_public": isPublic,
                    "cfg_showmoresixteen": showMore16,

                    "opt_wake": wakeUpTimeEnabled,
                    "opt_service": serviceEnabled,
                    "opt_exercise": exerciseEnabled,
                    "opt_lections": lectionsEnabled,
                    "opt_sleep": bedTimeEnabled]
        }
    }
}

protocol Profile {
    var ID : Int32 { get }
    var firstName : String { get }
    var lastName : String { get }
    var spiritualName : String { get }
    var login : String { get }
    var email : String { get }
    var registrationDate : Date { get }
}

extension Profile { // JSONConvertible
    var profileJson : JSON {
    return [
        "first_name": firstName,
        "last_name": lastName,
        "spiritual_name": spiritualName
        ]
    }
}



