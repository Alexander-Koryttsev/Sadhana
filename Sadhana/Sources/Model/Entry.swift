//
//  Entry.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/7/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



enum EntryFieldKey : String, FieldKey {
    case wakeUpTime
    case japa = "japa_rounds"
    case japa7_30 = "japaCount7_30"
    case japa10 = "japaCount10"
    case japa18 = "japaCount18"
    case japa24 = "japaCount24"
    case reading
    case readingInMinutes
    case kirtan
    case service
    case yoga
    case lections
    case bedTime
}

protocol Updatable {
    var dateUpdated : Date { get }
    var dateCreated : Date { get }
}

protocol Synchable : Updatable {
    var dateSynched : Date? { get }
}

extension Synchable {
    var shouldSynch : Bool {
        get {
            return dateUpdated > (dateSynched ?? dateCreated)
        }
    }
}

protocol Entry : Updatable, JSONConvertible {
    var ID : Int32? { get }
    var userID : Int32 { get }
    var date : Date { get }
    
    var japaCount7_30 : Int16 { get }
    var japaCount10 : Int16 { get }
    var japaCount18 : Int16 { get }
    var japaCount24 : Int16 { get }
    
    var reading : Time { get }
    var kirtan : Bool { get }
    
    var bedTime : Time? { get }
    var wakeUpTime : Time? { get }
    
    var yoga : Bool { get }
    var service : Bool { get }
    var lections : Bool { get }
}

extension Entry {
    var japaSum : Int16 {
        get {
            return japaCount7_30 + japaCount10 + japaCount18 + japaCount24
        }
    }

    var json : JSON {
        get {
            return ["entry_id": ID ?? NSNull(),
                    "created_at": dateCreated.remoteDateTimeString,
                    "updated_at": dateUpdated.remoteDateTimeString,
                    "user_id": userID,
                    "entrydate": date.remoteDateString,
                    "jcount_730": japaCount7_30,
                    "jcount_1000": japaCount10,
                    "jcount_1800": japaCount18,
                    "jcount_after": japaCount24,
                    "reading": reading.rawValue,
                    "kirtan": kirtan,
                    "opt_sleep": bedTime?.string ?? NSNull(),
                    "opt_wake_up": wakeUpTime?.string ?? NSNull(),
                    "opt_exercise": yoga,
                    "opt_service": service,
                    "opt_lections": lections]
        }
    }
}

protocol FieldKey {
    var rawValue : String {get}
}

