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

extension User {
    var userID : Int32 {
        return ID
    }
    var userName : String {
        return name
    }
}

protocol UserBriefInfo {
    var userID : Int32 { get }
    var userName : String { get }
    var avatarURL : URL? { get }
}

extension User {
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



