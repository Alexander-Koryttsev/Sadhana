//
//  ActivityIndicator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE


#endif

private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        return _source
    }
}

/**
Enables monitoring of sequence computation.

If there is at least one sequence computation in progress, `true` will be sent.
When all activities complete `false` will be sent.
*/
public class ActivityIndicator : SharedSequenceConvertibleType {
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, ActivityIndicator.Element> {
        return _loading
    }
    
    public typealias Element = Bool
    
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _variable = RxSwift.Variable(0)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    var isRunning : Bool {
        get {
            return _variable.value > 0
        }
    }

    public init() {
        _loading = _variable.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return Observable.using({ [unowned self] () -> ActivityToken<O.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }

    private func increment() {
        _lock.lock()
        _variable.value = _variable.value + 1
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _variable.value = _variable.value - 1
        _lock.unlock()
    }
}

class IndexedActivityIndicator : SharedSequenceConvertibleType {
    typealias Element = (Bool, Int)
    typealias SharingStrategy = DriverSharingStrategy

    private let lock = NSRecursiveLock()
    private var indexSet = IndexSet()
    private let loadingSubject = PublishSubject<Element>()
    private let loading: SharedSequence<SharingStrategy, Element>

    var isActive : Bool {
        return indexSet.count > 0
    }

    init() {
        loading = loadingSubject.asDriver(onErrorJustReturn: (false, 0))
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O, index: Int) -> Observable<O.Element> {
        return Observable.using({ [unowned self] () -> ActivityToken<O.Element> in
            self.increment(index)
            return ActivityToken(source: source.asObservable(), disposeAction:{
                self.decrement(index)
            })
        }) { t in
            return t.asObservable()
        }
    }

    private func increment(_ index: Int) {
        lock.lock()
        indexSet.insert(index)
        loadingSubject.onNext((true, index))
        lock.unlock()
    }

    private func decrement(_ index: Int) {
        lock.lock()
        indexSet.remove(index)
        loadingSubject.onNext((false, index))
        lock.unlock()
    }

    func has(index: Int) -> Bool {
        return indexSet.contains(index)
    }

    func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return loading
    }

    func asDriver(for index:Int) -> Driver<Bool> {
        return loading.filter { (running, indexInternal) -> Bool in
            return index == indexInternal
        }.map { (running, _) -> Bool in
            return running
        }
    }

    var isActiveDriver : Driver<Bool> {
        return loading.map { [unowned self] _ in self.isActive }.distinctUntilChanged()
    }
    
}


extension ObservableConvertibleType {
    public func track(_ activity: ActivityIndicator) -> Observable<Element> {
        return activity.trackActivityOfObservable(self)
    }
    public func track(activity: ActivityIndicator) -> Observable<Element> {
        return activity.trackActivityOfObservable(self)
    }
    public func trackActivity(_ activity: ActivityIndicator) -> Observable<Element> {
        return activity.trackActivityOfObservable(self)
    }
    func track(_ activity: IndexedActivityIndicator, index:Int) -> Observable<Element> {
        return activity.trackActivityOfObservable(self, index: index)
    }
}
