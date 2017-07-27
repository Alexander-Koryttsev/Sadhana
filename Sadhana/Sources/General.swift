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

enum GeneralError : Error {
    case error
    case noSelf
}

struct Local {
    static let service = LocalService.shared
    static let defaults = LocalDefaults.shared
}

struct Remote {
    static let service = RemoteService.shared
}



func desc(_ object:Any?) -> String {
    let anyObject : AnyObject = object as AnyObject
    guard let string = anyObject.description else { return ""}
    return string
}

protocol JSONConvertible {
    func json() -> JSON
}

extension String {
    var localized: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
}

extension Array {
    subscript(_ indexes: [Int]) -> Array<Element> {
        var array = [Element]()
        for i in indexes {
            array.append(self[i])
        }
        return array
    }
}
