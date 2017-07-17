//
//  LocalSadhanaEntry.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/8/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import CoreData

@objc(LocalSadhanaEntry)
class LocalSadhanaEntry: NSManagedObject, SadhanaEntry, JSONConvertible {
    
    @NSManaged public var bedTime: Date?
    @NSManaged public var date: Date
    @NSManaged public var month: Date
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateUpdated: Date
    @NSManaged public var exercise: Bool
    @NSManaged public var id: NSNumber?
    @NSManaged public var japaCount7_30: Int16
    @NSManaged public var japaCount10: Int16
    @NSManaged public var japaCount18: Int16
    @NSManaged public var japaCount24: Int16
    @NSManaged public var kirtan: Bool
    @NSManaged public var lections: Bool
    @NSManaged public var reading: Int16
    @NSManaged public var service: Bool
    @NSManaged public var userID: Int32
    @NSManaged public var wakeUpTime: Date?
    
    //TODO: check it
    var ID: Int32? { get {
        return id as? Int32
        } set {
            id = newValue as NSNumber?
        }
    }
    
    @discardableResult
    func map(_ sadhanaEntry: SadhanaEntry) -> Self {
        ID = sadhanaEntry.ID
        dateCreated = sadhanaEntry.dateCreated
        dateUpdated = sadhanaEntry.dateUpdated
        userID = sadhanaEntry.userID
        date = sadhanaEntry.date

        month = DateUtilities.monthFrom(date: date)
        japaCount7_30 = sadhanaEntry.japaCount7_30
        japaCount10 = sadhanaEntry.japaCount10
        japaCount18 = sadhanaEntry.japaCount18
        japaCount24 = sadhanaEntry.japaCount24
        reading = sadhanaEntry.reading
        kirtan = sadhanaEntry.kirtan
        bedTime = sadhanaEntry.bedTime
        wakeUpTime = sadhanaEntry.wakeUpTime
        exercise = sadhanaEntry.exercise
        service = sadhanaEntry.service
        lections = sadhanaEntry.lections

        return self
    }

    
    
    func json() -> JSON {
        return ["id": ID ?? NSNull(),
                "created_at": dateCreated.remoteDateTimeString(),
                "updated_at": dateUpdated.remoteDateTimeString(),
                "user_id": userID,
                "date": date.remoteDateString(),
                "jcount_730": japaCount7_30,
                "jcount_1000": japaCount10,
                "jcount_1800": japaCount18,
                "jcount_after": japaCount24,
                "reading": reading,
                "kirtan": kirtan,
                "opt_sleep": bedTime?.remoteTimeString() ?? NSNull(),
                "opt_wake_up": wakeUpTime?.remoteTimeString() ?? NSNull(),
                "opt_exercise": exercise,
                "opt_service": service,
                "opt_lections": lections]
    }
    
    static let entityName = "LocalSadhanaEntry"
    
    @nonobjc public class func request() -> NSFetchRequest<LocalSadhanaEntry> {
        return NSFetchRequest<LocalSadhanaEntry>(entityName: entityName)
    }
}

/*
 Example of raw JSON: {
 "id": "58035",
 "created_at": "2016-07-31 19:08:53",
 "updated_at": "2016-07-31 22:08:53",
 "user_id": "1",
 "date": "2016-07-30",
 "day": "30",
 "jcount_730": "14",
 "jcount_1000": "2",
 "jcount_1800": "9",
 "jcount_after": "0",
 "reading": "40",
 "kirtan": "1",
 "opt_sleep": null,
 "opt_wake_up": null,
 "opt_exercise": "0",
 "opt_service": "0",
 "opt_lections": "0"
 }
 */
