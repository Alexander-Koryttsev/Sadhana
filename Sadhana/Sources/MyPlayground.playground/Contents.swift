//: Playground - noun: a place where people can play

import Foundation

var components = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
components.day = components.day! - components.weekday! + 1
components.date
