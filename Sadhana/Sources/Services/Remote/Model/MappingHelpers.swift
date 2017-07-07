//
//  MappingHelpers.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/7/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import Mapper

func extractID(object: Any?) throws -> Int32 {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    if let id = Int32(string) {
        return id
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}

extension Int32 : Convertible {
    public static func fromMap(_ value: Any) throws -> Int32 {
        if let object = value as? Int {
            return Int32(object)
        }
        
        throw MapperError.convertibleError(value: value, type: ConvertedType.self)
    }
}


func extractDate(object: Any?) throws -> Date {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    if let date = formatter.date(from:string) {
        return date
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}

func extractDateAndTime(object: Any?) throws -> Date {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    if let date = formatter.date(from:string) {
        return date
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}

func extractTime(object: Any?) throws -> Date {
    guard let string = object as? String else {
        throw MapperError.convertibleError(value: object, type: String.self)
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    
    if let date = formatter.date(from:string) {
        return date
    }
    
    throw MapperError.convertibleError(value: object, type: String.self)
}
