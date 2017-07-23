//: Playground - noun: a place where people can play

import UIKit
import RxSwift

let date = Date(timeIntervalSince1970: 0)
var cal = Calendar(identifier: .gregorian)
cal.timeZone = TimeZone(secondsFromGMT: 0)?
cal.component(.hour, from: date)
var components = DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0), hour: 12, minute: 32)
components.date
