//
//  SadhanaEntry.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/7/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

protocol SadhanaEntry {
    var ID : Int32? { get }
    var userID : Int32 { get }
    var date : Date { get }
    
    var japaCount7_30 : Int16 { get }
    var japaCount10 : Int16 { get }
    var japaCount18 : Int16 { get }
    var japaCount24 : Int16 { get }
    
    var reading : Int16 { get }
    var kirtan : Bool { get }
    
    var bedTime : Date? { get }
    var wakeUpTime : Date? { get }
    
    var exercise : Bool { get }
    var service : Bool { get }
    var lections : Bool { get }
    
    var dateCreated : Date { get }
    var dateUpdated : Date { get }
}

extension SadhanaEntry {
    var japaSum : Int16 {
        get {
            return japaCount7_30 + japaCount10 + japaCount18 + japaCount24
        }
    }
}
