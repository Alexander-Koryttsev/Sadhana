//
//  RxCocoa+Extensions.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/13/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    /// Reactive wrapper for `text` property.
    public var textRequired: ControlProperty<String> {
        return valueRequired
    }
    
    /// Reactive wrapper for `text` property.
    public var valueRequired: ControlProperty<String> {
        return UIControl.valuePublic(
            base,
            getter: { textField in
                textField.text ?? ""
        }, setter: { textField, value in
            textField.text = value
        }
        )
    }    
}

extension Reactive where Base: UISearchBar {
    /// Reactive wrapper for `text` property.
    public var textRequired: ControlProperty<String> {
        return valueRequired
    }

    /// Reactive wrapper for `text` property.
    public var valueRequired: ControlProperty<String> {
        let source: Observable<String> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<String> in
            let text = searchBar?.text ?? ""

            return (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
                .map { a in
                    return a[1] as? String ?? ""
                }
                .startWith(text)
        }

        let bindingObserver = Binder(self.base) { (searchBar, text: String) in
            searchBar.text = text
        }

        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}


extension UIControl {
    static func valuePublic<T, ControlType: UIControl>(_ control: ControlType, getter:  @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> ()) -> ControlProperty<T> {
        let values: Observable<T> = Observable.deferred { [weak control] in
            guard let existingSelf = control else {
                return Observable.empty()
            }
            
            return (existingSelf as UIControl).rx.controlEvent([.allEditingEvents, .valueChanged])
                .flatMap { _ in
                    return control.map { Observable.just(getter($0)) } ?? Observable.empty()
                }
                .startWith(getter(existingSelf))
        }
        return ControlProperty(values: values, valueSink: Binder(control) { control, value in
            setter(control, value)
        })
    }
}


extension Reactive where Base: UIRefreshControl {
    var beginRefreshing: Binder<Void> {
        return Binder(self.base) { refreshControl, _ in
            refreshControl.beginRefreshing()
        }
    }

    var endRefreshing: Binder<Void> {
        return Binder(self.base) { refreshControl, _ in
            refreshControl.endRefreshing()
        }
    }
}
