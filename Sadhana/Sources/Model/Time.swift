//
//  Time.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/24/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



struct Time : Equatable {
    var hour: Int16 {
        return (rawValue - minute)/60
    }

    var hourString: String {
        return String(format:"%02d", hour)
    }

    var minute: Int16 {
        return rawValue % 60
    }

    var minuteString: String {
        return String(format:"%02d", minute)
    }

    var string: String {
        return String(format:"%02d:%02d", hour, minute)
    }

    var shortString: String {
        if hour > 0 {
            return "\(hour):\(minuteString)"
        }
        else {
            return minute.description
        }
    }

    let rawValue: Int16

    var nsNumber: NSNumber {
        get {
            return NSNumber(value: rawValue)
        }
    }

    init(rawValue:Int16) {
        self.rawValue = rawValue
    }

    init(rawValue:Int) {
        self.rawValue = Int16(rawValue)
    }

    init(rawValue:NSNumber) {
        self.rawValue = rawValue.int16Value
    }

    init?(rawValue:NSNumber?) {
        guard let rawValue = rawValue else { return nil }
        self.rawValue = rawValue.int16Value
    }

    init?(rawValue:String) {
        guard let rawInt16 = Int16(rawValue) else { return nil }
        self.rawValue = rawInt16
    }

    init(hour:Int16, minute:Int16) {
        self.init(rawValue: hour*60 + minute)
    }

    init?(hour:String, minute:String) {

        var hourInt = Int16(hour)
        var minuteInt = Int16(minute)

        if hourInt == nil && minuteInt != nil {
            hourInt = 0
        }
        else if hourInt != nil && minuteInt == nil {
            minuteInt = 0
        }

        guard   let hourIntLet = hourInt,
                let minuteIntLet = minuteInt
        else { return nil }

        self.init(hour: hourIntLet, minute: minuteIntLet)
    }

    init(_ time:Time) {
        self.init(hour: time.hour, minute: time.minute)
    }

    init?(_ time:String) {
        let components = time.components(separatedBy: ":")

        guard   let hour = components.first,
            let minute = components.last
            else { return nil }

        self.init(hour: hour, minute: minute)
    }

    public static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
