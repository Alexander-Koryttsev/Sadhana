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
        return ControlProperty(values: values, valueSink: UIBindingObserver(UIElement: control) { control, value in
            setter(control, value)
        })
    }
}
