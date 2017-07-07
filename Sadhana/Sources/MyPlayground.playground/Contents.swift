//: Playground - noun: a place where people can play

import UIKit
import RxSwift

enum JustError : Error {
    case error
}

var ob1 = Observable<Any>.error(JustError.error).catchError { (error) -> Observable<Any> in
    
    let signal = Completable.create(subscribe: { (observer) -> Disposable in
        observer(.completed)
        return Disposables.create {}
    })
    return Observable<Any>.just(1).after(signal)
}
var ob2 = Observable<Any>.just(2)
var ob3 = ob1.after(ob2).debug().subscribe()

