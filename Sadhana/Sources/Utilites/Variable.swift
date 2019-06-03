//
//  Variable.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 3/2/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

class Variable<Element> : ObserverType, ObservableType, Fillable {

    var value : Element {
        get {
            fatalError("Value getter should be overriden")
        }

        set {
            self.observers.forEach { (_, observer) in
                observer.onNext(value)
            }
        }
    }

    var driver : Driver<Element> {
        let emptyValue : Element
        if Element.self == String.self {
            emptyValue = "" as! Element
        }
        else if Element.self == Bool.self {
            emptyValue = false as! Element
        }
        else if Element.self == Int.self {
            emptyValue = 0 as! Element
        }
        else if Element.self == Int16.self {
            emptyValue = 0 as! Element
        }
        else if Element.self == Int32.self {
            emptyValue = 0 as! Element
        }
        else if Element.self == Void.self {
            emptyValue = () as! Element
        }
        else if Element.self == Optional<Any>.self {
            emptyValue = () as! Element
        }
        else if Element.self == Time.self {
            emptyValue = Time(rawValue: 0) as! Element
        }
        else {
            fatalError("Unknown Element type \(Element.self)")
        }

        return asDriver(onErrorJustReturn: emptyValue)
    }

    var isFilled: Bool {
        if Element.self == Void.self {
            return true
        }

        if let string = value as? String {
            return string.count > 0
        }
        if let int = value as? Int {
            return int > 0
        }
        if let int = value as? Int16 {
            return int > 0
        }
        if let int = value as? Int32 {
            return int > 0
        }
        if let time = value as? Time {
            return time.rawValue > 0
        }

        if Element.self == Optional<Any>.self {
            let optional = value as Optional<Any>
            return optional != nil
        }



        return true
    }

    func set(value: Element) {
        self.value = value
    }

    private var observers = [Date : AnyObserver<Element>]()

    func on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            value = element
            break

        default: break
        }
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
        let date = Date()
        observers[date] = AnyObserver<Element>(observer)
        observer.onNext(value)

        return Disposables.create { [weak self] in
            self?.observers.removeValue(forKey: date)
        }
    }

}

class StoredVariable<Element> : Variable<Element> {
    override var value : Element {
        get {
            return valueInternal
        }
        set {
            valueInternal = newValue
            super.value = newValue
        }
    }
    private var valueInternal: Element

    init(_ value : Element) {
        valueInternal = value
    }
}

class KeyPathVariable<Object, Value> : Variable<Value> {
    typealias KP = ReferenceWritableKeyPath <Object, Value>
    fileprivate var object : Object
    fileprivate let keyPath : KP

    override var value : Value {
        get {
            return object[keyPath: keyPath]
        }
        set {
            object[keyPath: keyPath] = newValue
            super.value = newValue
        }
    }

    init(_ object : Object, _ keyPath : KP) {
        self.object = object
        self.keyPath = keyPath
    }
}

class ManagedKeyPathVariable<Object:ManagedObject, Value> : KeyPathVariable<Object, Value> {
    override var value : Value {
        didSet {
            if let updatable = object as? ManagedUpdatable {
                updatable.dateUpdated = Date()
            }
        }
    }
}

class AutoSaveKeyPathVariable<Object:ManagedObject, Value> : ManagedKeyPathVariable<Object, Value> {
    override var value : Value {
        didSet {
            object.managedObjectContext?.saveHandled()
        }
    }

}
