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
        try ID = map.from("id")
        try title = map.from("title")
    }
}

struct City : Mappable, Titled {
    let ID : Int32
    let title : String
    let important : Bool
    let area : String?
    let region : String?

    init(map: Mapper) throws {
        try ID = map.from("id")
        try title = map.from("title")
        important = map.optionalFrom("important") ?? false
        area = map.optionalFrom("area")
        region = map.optionalFrom("region")
    }
    
    var subtitle: String? {
        var string = area ?? ""
        if let region = region {
            if string.count > 0 {
                string.append(", ")
            }
            string.append(region)
        }
        return string
    }
}

