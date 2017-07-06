//
//  User.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

protocol User {
    var ID : Int { get }
    var name : String { get }
    var avatarURL : URL? { get }
}
