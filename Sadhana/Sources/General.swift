//
//  General.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

struct Config {
    #if DEV
        static let baseHostPrefix = "dev."
        static let disableServerCertficate = true
    #else
        static let baseHostPrefix = ""
        static let disableServerCertficate = false
    #endif

    #if DEBUG
        static let defaultLogin = "sanio91@ya.ru"
        static let defaultPassword = "Ale248Vai"
    #else
        static let defaultLogin = ""
        static let defaultPassword = ""
    #endif
}

typealias JSON = [String: Any]
typealias JSONArray = [JSON]
typealias Block = () -> Void

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

struct Main {
    static let service = MainService.shared
}

protocol JSONConvertible {
    var json : JSON { get }
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

extension UIImage {
    static func screenSized(_ name:String) -> UIImage? {
        return UIImage(named:name.appending("-\(Int(UIScreen.main.bounds.size.width))w")) ?? UIImage(named:name)
    }
}

extension UIImageView {
    convenience init(screenSized name:String) {
        self.init(image: UIImage.screenSized(name))
    }
}

func desc(_ object:Any?) -> String {
    let anyObject : AnyObject = object as AnyObject
    guard let string = anyObject.description else { return ""}
    return string
}

func screenWidthSecific<T>(w320:T, w375:T?, w414:T?) -> T {
    switch UIScreen.main.bounds.size.width {
        case 320: return w320
        case 375: return w375 ?? w320
        case 414: return w414 ?? w375 ?? w320

        default: return w320
    }
}

func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if LOG
        let stringItem = items.map {"\($0)"} .joined(separator: separator)
        print(stringItem, terminator: terminator)
    #endif
}

