//
//  Entry.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/7/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

enum EntryFieldKey : String {
    case wakeUpTime = "wakeUpTime"
    case japa = "japa_rounds"
    case japa7_30 = "japaCount7_30"
    case japa10 = "japaCount10"
    case japa18 = "japaCount18"
    case japa24 = "japaCount24"
    case reading = "reading"
    case kirtan = "kirtan"
    case service = "service"
    case yoga = "yoga"
    case lections = "lections"
    case bedTime = "bedTime"
}

protocol Entry {
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
    
    var dateCreated : Date { get }
    var dateUpdated : Date { get }
}

extension Entry {
    var japaSum : Int16 {
        get {
            return japaCount7_30 + japaCount10 + japaCount18 + japaCount24
        }
    }
}
