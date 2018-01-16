//
//  Country.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/1/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import Foundation
import Mapper

struct Country : Mappable, Titled {
    let ID : Int32
    let title : String

    init(map: Mapper) throws {
        try ID = map.from("cid")
        try title = map.from("title")
    }
}

struct City : Mappable, Titled {
    let ID : Int32
    let title : String
    let important : Bool

    init(map: Mapper) throws {
        try ID = map.from("cid")
        try title = map.from("title")
        important = map.optionalFrom("important") ?? false
    }
}

