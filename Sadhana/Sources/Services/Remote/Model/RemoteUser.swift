//
//  RemoteUser.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import Mapper

struct RemoteUser : User, Mappable {
    let ID : Int
    let name : String
    let avatarURL: URL?
    
    init(map: Mapper) throws {
        try ID = map.from("userid", transformation: extractID)
        try name = map.from("user_name")
        avatarURL = map.optionalFrom("avatar_url")
    }
}

enum ConvertibleError : Error {
    case error
}

private func extractID(object: Any?) throws -> Int {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    if let id = Int(string) {
        return id
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}
