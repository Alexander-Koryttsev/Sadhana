//
//  General.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/26/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import AlamofireImage

struct Config {
    #if DEV
        static let host = "dev.vaishnavaseva.net"
    #else
        static let host = "vaishnavaseva.net"
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

protocol OptionalProtocol {}
extension Optional : OptionalProtocol {}

enum GeneralError : Error {
    case error
    case noSelf
}

let Device = UIDevice.current
let iOS = NSString(string: Device.systemVersion).integerValue
let Screen = UIScreen.main
let iPhone = UI_USER_INTERFACE_IDIOM() == .phone
let iPhoneX = max(Screen.bounds.size.width, Screen.bounds.size.height) == 812.0
let iPad = UI_USER_INTERFACE_IDIOM() == .pad

func iOS(_ version: Int) -> Bool {
    return iOS >= version
}

struct Local {
    static let service = LocalService{}
    static let defaults = LocalDefaults()
}

struct Remote {
    static let service = RemoteService()
    
    enum URL : String {
        static let prefix = "https://\(Config.host)/"
        
        case api = "vs-api/v2/sadhana"
        case authToken = "?oauth=token"
        case defaultAvatar = "wp-content/themes/socialize-child/img/default_avatar.png"
        
        var fullString : String {
            get {
                return "\(URL.prefix)\(rawValue)"
            }
        }
        
        var urlValue : Foundation.URL {
            return Foundation.URL(string:fullString)!
        }
        
        var path : String {
            return rawValue
        }
    }
}

struct Main {
    static let service = MainService.shared
}

class Common {
    static let shared = Common()
    let calendar : Calendar
    private var dates = [[Date]]()

    init() {
        var cal = Calendar.current
        cal.timeZone = TimeZone.create()
        calendar = cal
    }

    var calendarDates : [[Date]] {
        get {
            if dates.count == 0 || dates.first!.first! != Date().trimmedTime {
                dates.removeAll()
                var month = [Date]()
                var date = Date().trimmedTime
                var stop = false

                while !stop {
                    month.append(date)

                    if calendar.component(.day, from: date) == 1,
                        month.count > 0 {
                        dates.append(month)
                        month.removeAll()
                    }

                    stop = dates.count == 24
                    date = calendar.date(byAdding: .day, value: -1, to: date)!
                }
            }
            return dates
        }
    }

    static let avatarFilter = CircleFilter()
    static let avatarPlaceholder = #imageLiteral(resourceName: "default-avatar").af_imageRoundedIntoCircle()
}

protocol JSONConvertible {
    var json : JSON { get }
}

extension NSObject {
    static var classString : String {
        return NSStringFromClass(self)
    }
    var classString : String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
}

extension String {
    var localized: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }

    var capitalizedFirstLetter: String {
        return prefix(1).uppercased() + dropFirst()
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

    var avatarURL : URL? {
        get {
            return nil
        }
        set {
            if let url = newValue {
                af_setImage(withURL: url, placeholderImage:Common.avatarPlaceholder, filter:Common.avatarFilter, imageTransition:.crossDissolve(0.25))
            }
        }
    }
}

extension UIView {
    func removeAllSubviews() {
        subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
    }
}

func desc(_ object:Any?) -> String {
    let anyObject : AnyObject = object as AnyObject
    guard let string = anyObject.description else { return ""}
    return string
}

func screenWidthSpecific<T>(w320:T, w375:T?, w414:T?) -> T {
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

func remoteLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if REMOTE_LOG
        let stringItem = items.map {"\($0)"} .joined(separator: separator)
        print(stringItem, terminator: terminator)
    #endif
}

