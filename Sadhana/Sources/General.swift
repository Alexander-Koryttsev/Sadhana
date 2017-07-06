//
//  General.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]
typealias JSONArray = [JSON]

func desc(_ object:Any?) -> String {
    let anyObject : AnyObject = object as AnyObject
    guard let string = anyObject.description else { return ""}
    return string
}

protocol JSONConvertible {
    func json() -> JSON
}
