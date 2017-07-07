//
//  User.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

protocol User {
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


