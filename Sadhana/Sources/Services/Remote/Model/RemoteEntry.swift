//
//  RemoteEntry.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/7/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import Mapper

struct RemoteEntry : Entry, UserBriefInfo, Mappable {
    let ID : Int32?
    let userID : Int32
    let date : Date
    
    let japaCount7_30 : Int16
    let japaCount10 : Int16
    let japaCount18 : Int16
    let japaCount24 : Int16
    
    let reading : Time
    let kirtan : Bool
    
    let bedTime : Time?
    let wakeUpTime : Time?
    
    let yoga : Bool
    let service : Bool
    let lections : Bool
    
    let dateCreated : Date
    let dateUpdated : Date

    let userName : String
    let avatarURL : URL?

    init(map: Mapper) throws {
        try ID = map.from("id", transformation: extractID)
        try userID = map.from("user_id", transformation: extractID)
        try date = map.from("date", transformation: extractDate)
        
        try japaCount7_30 = map.from("jcount_730")
        try japaCount10 = map.from("jcount_1000")
        try japaCount18 = map.from("jcount_1800")
        try japaCount24 = map.from("jcount_after")
        
        try reading = map.from("reading", transformation: extractTimeFromRawValue)
        try kirtan = map.from("kirtan")
        
        bedTime = map.optionalFrom("opt_sleep", transformation: extractTimeFromString)
        wakeUpTime = map.optionalFrom("opt_wake_up", transformation: extractTimeFromString)

        try yoga = map.from("opt_exercise")
        try service = map.from("opt_service")
        try lections = map.from("opt_lections")
        
        try dateCreated = map.from("created_at", transformation: extractDateAndTime)
        try dateUpdated = map.from("updated_at", transformation: extractDateAndTime)

        
        var userNameLocal = map.optionalFrom("spiritual_name") as String?
        
        if userNameLocal == nil || userNameLocal!.isEmpty {
            userNameLocal = map.optionalFrom("karmic_name")
        }
        if userNameLocal == nil || userNameLocal!.isEmpty {
            userNameLocal = map.optionalFrom("user_nicename")
        }
        
        userName = userNameLocal ?? ""
        
        avatarURL = map.optionalFrom("avatarUrl")
    }
}

struct AllEntriesResponse : Mappable {
    let entries : [RemoteEntry]
    let total : Int
    let page : Int
    let pageSize : Int

    init(map: Mapper) throws {
        try entries = map.from("entries")
        try total = map.from("total_found", transformation:extractInt)
        try page = map.from("filter.page_num", transformation:extractInt)
        try pageSize = map.from("filter.items_per_page", transformation:extractInt)
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
