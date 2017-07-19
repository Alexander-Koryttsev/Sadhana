//
//  MappingHelpers.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/7/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import Mapper

class MappingHelper {
    static let shared = MappingHelper()
    
    let dateTimeFormatter = DateFormatter.create()
    let dateFormatter = DateFormatter.create()
    let timeFormatter = DateFormatter.create()
    
    init() {
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm"
    }
}

extension DateFormatter {
    static func create() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.create()
        return formatter
    }
}

extension TimeZone {
    static func create() -> TimeZone {
        return TimeZone(secondsFromGMT:0)!
    }
}

extension Date {
    func remoteDateString() -> String {
        return MappingHelper.shared.dateFormatter.string(from: self)
    }
    func remoteDateTimeString() -> String {
        return MappingHelper.shared.dateTimeFormatter.string(from: self)
    }
    func remoteTimeString() -> String {
        return MappingHelper.shared.timeFormatter.string(from: self)
    }
}

extension Int32 : Convertible {
    public static func fromMap(_ value: Any) throws -> Int32 {
        if let object = value as? Int {
            return Int32(object)
        }
        if let object = value as? String {
            if let object1 = Int32(object) {
                return object1
            }
        }
        throw MapperError.convertibleError(value: value, type: ConvertedType.self)
    }
}

extension Int16 : Convertible {
    public static func fromMap(_ value: Any) throws -> Int16 {
        if let int = value as? Int {
            return Int16(int)
        }
        if let string = value as? String {
            if let int16 = Int16(string) {
                return int16
            }
        }
        
        throw MapperError.convertibleError(value: value, type: ConvertedType.self)
    }
}

extension Mapper {
    public func from<T:LosslessStringConvertible & Convertible>(_ field: String) throws -> T  where T == T.ConvertedType {
        return try self.from(field, transformation: extractObject)
    }
}

func extractObject<T:LosslessStringConvertible>(value:Any?) throws -> T {
    
    if T.self is Bool.Type {
        return try extractBool(value: value) as! T
    }
    
    if let object = value as? T {
        return object
    }
    
    if let string = value as? String {
        if let object = T(string) {
            return object
        }
    }
    
    throw MapperError.convertibleError(value: value, type: T.self)
}

func extractBool(value:Any?) throws -> Bool {
    if let object = value as? Bool {
        return object
    }
    
    if let string = value as? String {
        if let object = Bool(string) {
            return object
        }
        if let int = Int(string) {
            return int != 0
        }
    }
    
    return false
}

func extractID(object: Any?) throws -> Int32 {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    if let id = Int32(string) {
        return id
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}

func extractDate(object: Any?) throws -> Date {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    if let date = MappingHelper.shared.dateFormatter.date(from:string) {
        return date
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}

func extractDateAndTime(object: Any?) throws -> Date {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    if let date = MappingHelper.shared.dateTimeFormatter.date(from:string) {
        return date
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}

func extractTime(object: Any?) throws -> Date {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    if let date = MappingHelper.shared.timeFormatter.date(from:string) {
        return date
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}
