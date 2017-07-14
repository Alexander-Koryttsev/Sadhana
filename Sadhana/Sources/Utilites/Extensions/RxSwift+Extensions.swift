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

extension PrimitiveSequence where Trait == SingleTrait {
    func concat(_ second: Completable) -> Single<PrimitiveSequence.ElementType> {
        return self.asObservable().concat(second).asSingle()
    }
    
    func map<T>(object:T.Type) -> Single<T> where T:Mappable {
        return self.asObservable().map(object:object).asSingle()
    }
    
    func map<T>(array:T.Type) -> Single<[T]> where T:Mappable {
        return self.asObservable().map(array:array).asSingle()
    }
    func cast<T>(_ type: T.Type) -> Single<T> {
        return self.asObservable().cast(type).asSingle()
    }
    func cast<T>(array elementType: T.Type) -> Single<[T]> {
        return self.asObservable().cast(array: elementType).asSingle()
    }
    
    func after(_ first: Completable) -> Single<PrimitiveSequence.ElementType> {
        return self.asObservable().after(first).asSingle()
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    func concat<T>(_ second: Single<T>) -> Single<T> {
        return Single<T>.create(subscribe: { (observer) -> Disposable in
            _ = self.asObservable().subscribe(onError: { (error) in
                observer(.error(error))
            }, onCompleted: { 
                _ = second.subscribe(onSuccess: { (value) in
                    observer(.success(value))
                }, onError: { (error) in
                    observer(.error(error))
                })
            });
            
            return Disposables.create {}
        })
    }
}

extension ObservableType {
    func concat(_ second: Completable) -> Observable<Self.E> {
        return self.concat(second.asObservable().cast(Self.E.self))
    }
    
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
            _ = first.asObservable().subscribe(onError: { (error) in
                subscriber.onError(error)
            }, onCompleted: {
                _ = self.subscribe(subscriber)
            })
            return Disposables.create {}
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


