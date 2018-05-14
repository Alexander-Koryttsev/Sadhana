//
//  RemoteUser.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import Mapper

struct RemoteUser : User, Mappable {
    let ID : Int32
    let name : String
    let avatarURL: URL?
    
    let isPublic : Bool
    let showMore16 : Bool
    
    let wakeUpTimeEnabled : Bool
    let serviceEnabled : Bool
    let exerciseEnabled : Bool
    let lectionsEnabled : Bool 
    let bedTimeEnabled : Bool 
    
    init(map: Mapper) throws {
        try ID = map.from("userid", transformation: extractID)
        try name = map.from("user_name")
        avatarURL = map.optionalFrom("avatar_url")
        
        try isPublic = map.from("cfg_public")
        try showMore16 = map.from("cfg_showmoresixteen")
        
        try wakeUpTimeEnabled = map.from("opt_wake")
        try serviceEnabled = map.from("opt_service")
        try exerciseEnabled = map.from("opt_exercise")
        try lectionsEnabled = map.from("opt_lections")
        try bedTimeEnabled = map.from("opt_sleep")
    }
}

enum ConvertibleError : Error {
    case error
}

struct RemoteProfile : Profile, Mappable {
    var ID : Int32
    var firstName : String
    var lastName : String
    var spiritualName : String
    var registrationDate : Date
    var login : String
    var email : String

    init(map: Mapper) throws {
        try ID = map.from("userid", transformation: extractID)

        try firstName = map.from("first_name")
        try lastName = map.from("last_name")
        spiritualName = map.optionalFrom("spiritual_name") ?? ""

        try login = map.from("login")
        try email = map.from("email")
        try registrationDate = map.from("registration_date", transformation: extractDateAndTime)
    }

    /*
     "userid": "2",
     "first_name": "Mykola",
     "last_name": "Kutsyi",
     "spiritual_name": null,
     "login": "adminus",
     "email": "n.p.kutsyy@gmail.com",
     "registration_date": "2014-08-14 18:58:58",*/
}

class Registration: JSONConvertible {
    var spiritualName = ""
    var firstName = ""
    var lastName = ""
    var password = ""
    var email = ""
    var country = ""
    var city = ""
    var birthday : Date?

    var json: JSON {
        return ["spiritual_name": spiritualName,
                "first_name": firstName,
                "last_name": lastName,
                "password": password,
                "email": email,
                "country": country,
                "city": city,
                "birthday": birthday?.remoteDateString ?? ""]
    }
}

