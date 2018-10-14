//
//  RxSwift+Extensions.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/27/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



import Mapper

extension ObservableType {    
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

    func filterAll() -> Observable<E> {
        return filter{_ in false}
    }
}


extension ObservableConvertibleType {
    public func asBoolNoErrorObservable() -> Observable<Bool> {
        return asObservable().map({ (object) -> Bool in
            return true
        })
        .catchErrorJustReturn(false)
    }
    public func mapTrue() -> Observable<Bool> {
        return asObservable().map{_ in true}
    }
}

