//
//  LocalDefaults.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/11/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

class LocalDefaults {
    enum Key : String {
        case prefix = "LocalDefaults"
        case tokens
        case entriesUpdatedDate
        case userID
        case optionFields
        case otherGraphsEnabled
        case guidesShown

        var string : String {
            get {
                return Key.prefix.rawValue.appending(rawValue.capitalized)
            }
        }
    }

    private let keyPrefix = "LocalDefaults"
    
    var userID: Int32? {
        get {
            return Int32(integer(for: .userID))
        }
        set {
            set(newValue, for:.userID)
        }
    }

    var optionFields : [String : Bool] {
        get {
            return dictionary(for:.optionFields) as? [String : Bool] ?? [String : Bool]()
        }
        set {
            set(newValue, for: .optionFields)
        }
    }

    var tokens : JSON? {
        get {
            return dictionary(for: .tokens)
        }
        set {
            set(newValue, for: .tokens)
        }
    }

    var entriesUpdatedDate : Date? {
        get {
            return value(for: .entriesUpdatedDate) as? Date
        }
        set {
            set(newValue, for: .entriesUpdatedDate)
        }
    }

    var guidesShown : [String : Bool] {
        get {
            return dictionary(for:.guidesShown) as? [String : Bool] ?? [String : Bool]()
        }
        set {
            set(newValue, for: .guidesShown)
        }
    }

    var shouldShowGuideCompletion = false

    func set(field:EntryFieldKey, enabled:Bool) {
        var fields = optionFields
        fields[field.rawValue] = !enabled
        optionFields = fields
    }

    func isFieldEnabled(_ field:EntryFieldKey) -> Bool {
        return optionFields[field.rawValue] ?? false
    }

    func set(guide:NSObject, shown:Bool) {
        var guides = guidesShown
        guides[guide.classString] = shown
        guidesShown = guides
    }

    func isGuideShown(_ guide:NSObject) -> Bool {
        log("isGuide \(guide) shown \(guidesShown[guide.classString] ?? false)")
        log("guides:\(guidesShown)")
        return guidesShown[guide.classString] ?? false
    }

    func resetGuide() {
        guidesShown = [:]
        log("guides:\(guidesShown)")
    }

    func reset() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.synchronize()
    }

    private func string(for key:Key) -> String? {
        return UserDefaults.standard.string(forKey: key.string)
    }

    private func bool(for key:Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.string)
    }

    private func integer(for key:Key) -> Int {
        return UserDefaults.standard.integer(forKey: key.string)
    }

    private func dictionary(for key:Key) -> [String : Any]? {
        return UserDefaults.standard.dictionary(forKey: key.string)
    }

    private func value(for key:Key) -> Any? {
        return UserDefaults.standard.value(forKey: key.string)
    }

    private func remove(for key:Key) {
        UserDefaults.standard.removeObject(forKey: key.string)
        UserDefaults.standard.synchronize()
    }

    private func set(_ value:Any?, for key:Key) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: key.string)
        }
        else {
            UserDefaults.standard.removeObject(forKey: key.string)
        }
        UserDefaults.standard.synchronize()
    }
}
