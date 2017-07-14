//: Playground - noun: a place where people can play

import UIKit
import RxSwift

enum JustError : Error {
    case error
}

var ob1 = Observable<Any>.just(1)
var ob2 = Observable<Any>.just(2)
var ob3 = Observable.combineLatest(ob1, ob2){ (v1, v2) in
    return 3
}.debug()
ob3.subscribe()

