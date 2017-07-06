//
//  RxSwift+Extensions.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/27/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift
import Mapper

extension ObservableType {
    func completable() -> Completable {
        let completable = Completable.create { (completable) -> Disposable in
            return self.subscribe(onNext: { (object) in
            }, onError: { (error) in
                completable(.error(error))
            }, onCompleted: {
                completable(.completed)
            })
        }
        
        return completable
    }
    
    func after<O>(_ first: O) -> RxSwift.Observable<Self.E> where O : ObservableConvertibleType {
        return Observable<Self.E>.create({ (subscriber) -> Disposable in
            return first.asObservable().subscribe(onError: { (error) in
                subscriber.onError(error)
            }, onCompleted: {
                _ = self.subscribe(subscriber)
            })
        })
    }
    
    func cast<T>(_ type: T.Type) -> Observable<T> {
        return self.map({ (element) -> T in
            return element as! T
        })
    }
    func cast<T>(array elementType: T.Type) -> Observable<[T]> {
        return self.map({ (element) -> [T] in
            return element as! [T]
        })
    }
}

extension PrimitiveSequence {
    func completable() -> Completable {
        return self.asObservable().completable()
    }
}

public enum RxObjectMapperError: Error {
    case parsingError
}

extension ObservableType where E:Any {
     func map<T>(object:T.Type) -> Observable<T> where T:Mappable {
        
        return self.map { (element) -> T in
            guard let jsonElement = element as? NSDictionary else {
                throw RxObjectMapperError.parsingError
            }
            let parsedElement = try T(map:Mapper(JSON:jsonElement))
            
            return parsedElement
        }
    }
    
    func map<T>(array:T.Type) -> Observable<[T]> where T:Mappable {
        return self.map { (elements) -> [T] in
            
            guard let jsonElements = elements as? [NSDictionary] else {
                throw RxObjectMapperError.parsingError
            }
            
            let parsedElements = try? jsonElements.map { try T(map: Mapper(JSON: $0)) }
            
            if parsedElements == nil {
                throw RxObjectMapperError.parsingError
            }
            
            return parsedElements!
        }
    }
}


