//
//  Variable.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 3/2/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

class Variable<T> : ObserverType, ObservableType {

    typealias E = T

    var value : T {
        get {
            fatalError("Value getter should be overriden")
        }

        set {
            self.observers.forEach { (_, observer) in
                observer.onNext(value)
            }
        }
    }

    var driver : Driver<T> {
        get {
            let emptyValue : T
            if T.self == String.self {
                emptyValue = "" as! T
            }
            else if T.self == Bool.self {
                emptyValue = false as! T
            }
            else if T.self == Int.self {
                emptyValue = 0 as! T
            }
            else if T.self == Int16.self {
                emptyValue = 0 as! T
            }
            else if T.self == Int32.self {
                emptyValue = 0 as! T
            }
            else if T.self == Void.self {
                emptyValue = () as! T
            }
            else if T.self == Optional<Any>.self {
                emptyValue = () as! T
            }
            else {
                fatalError("Unknown T type \(T.self)")
            }

            return asDriver(onErrorJustReturn: emptyValue)
        }
    }

    func set(value: T) {
        self.value = value
    }

    private var observers = [Date : AnyObserver<T>]()

    func on(_ event: Event<T>) {
        switch event {
        case .next(let element):
            value = element
            break

        default: break
        }
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == T {
        let date = Date()
        observers[date] = AnyObserver<E>(observer)
        observer.onNext(value)

        return Disposables.create { [weak self] in
            self?.observers.removeValue(forKey: date)
        }
    }

}

class StoredVariable<T> : Variable<T> {
    override var value : T {
        get {
            return valueInternal
        }
        set {
            valueInternal = newValue
            super.value = newValue
        }
    }
    private var valueInternal: T

    init(_ value : T) {
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
    var autosave = false

    override var value : Value {
        didSet {
            if let updatable = object as? ManagedUpdatable {
                updatable.dateUpdated = Date()
            }
            if autosave {
                object.managedObjectContext?.saveHandled()
            }
        }
    }
}

class AutoSaveKeyPathVariable<Object:ManagedObject, Value> : ManagedKeyPathVariable<Object, Value> {
    override var autosave : Bool { get { return false }
                                   set {} }
}
