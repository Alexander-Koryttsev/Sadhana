//: Playground - noun: a place where people can play

import UIKit
import RxSwift

let dateFormatter = DateFormatter()
dateFormatter.dateFormat =  "LLLL YYYY"
dateFormatter.locale = Locale(identifier: "RU")
dateFormatter.string(from: Date()).capitalized
