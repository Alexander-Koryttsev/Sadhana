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
    
    var userID: Int32? {
        get {
            return Int32(UserDefaults.standard.integer(forKey: userIDKey))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIDKey)
        }
    }
}
