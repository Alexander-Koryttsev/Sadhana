//: Playground - noun: a place where people can play

import Foundation
import RxSwift

var count = 90

Calendar.current.enumerateDates(startingAfter: Date(), matching: DateComponents(hour:0, minute:0), matchingPolicy: .strict, direction: .backward, using: { (date, exactMatch, stop) in

    guard let date = date else { return }

    print(date)

    count -= 1
    stop = count == 0
});