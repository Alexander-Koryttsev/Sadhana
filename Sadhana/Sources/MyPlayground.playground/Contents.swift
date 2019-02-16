//: Playground - noun: a place where people can play
import UIKit
import Foundation

let date1 = Date()
let date2 = Calendar.current.date(from: DateComponents.init(calendar: Calendar.current, year: 2019, month: 2, day: 1))!


Calendar.current.date(byAdding: .month, value: 2, to: date2)! > date1
