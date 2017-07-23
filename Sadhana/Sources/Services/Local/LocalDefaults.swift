//
//  LocalDefaults.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

class LocalDefaults {
    static let shared = LocalDefaults()
    
    private static let keyPrefix = "LocalDefaults"
    private let userIDKey = "\(keyPrefix)UserID"
    private let optionFieldsKey = "\(keyPrefix)OptionFields"
    
    var userID: Int32? {
        get {
            return Int32(UserDefaults.standard.integer(forKey: userIDKey))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIDKey)
            UserDefaults.standard.synchronize()
        }
    }

    var optionFields : [String : Bool] {
        get {
            return UserDefaults.standard.dictionary(forKey: optionFieldsKey) as? [String : Bool] ?? [String : Bool]()
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: optionFieldsKey)
            UserDefaults.standard.synchronize()
        }
    }

    func set(field:SadhanaEntryFieldKey, enabled:Bool) {
        var fields = optionFields
        fields[field.rawValue] = !enabled
        optionFields = fields
    }

    func isFieldEnabled(_ field:SadhanaEntryFieldKey) -> Bool {
        return optionFields[field.rawValue] == false || optionFields[field.rawValue] == nil
    }



    func reset() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.resetStandardUserDefaults()
    }
}
