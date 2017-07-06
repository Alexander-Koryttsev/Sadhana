import Foundation
import RxSwift

let ob1 = Observable<Any>.just(1)
let ob2 = Observable<Any>.just(2)
let ob12 = ob2.after(ob1)


//ob12.subscribe { (event) in
//    print(event)
//}

public extension ObservableType {
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
    
    public func after<O>(_ first: O) -> RxSwift.Observable<Self.E> where O : ObservableConvertibleType {
        return Observable<Self.E>.create({ (subscriber) -> Disposable in
            return first.asObservable().subscribe(onError: { (error) in
                subscriber.onError(error)
            }, onCompleted: {
                _ = self.subscribe(subscriber)
            })
        })
    }
}
