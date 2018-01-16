//
//  FormPickerVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/5/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit

import RxCocoa

class FormPickerVM: BaseTableVM {
    let title : String
    let search = Variable("")
    let select = PublishSubject<IndexPath>()
    let dataDidReload : Driver<[Titled]>

    init<T:Titled>(fieldVM: PickerFieldVM, load: Single<[T]>) {
        self.title = fieldVM.key
        dataDidReload = Driver.combineLatest(load.asDriver(onErrorJustReturn: [T]()), search.asDriver()) { (items, string) -> [Titled] in
            if string.count == 0 {
                return items
            }
            return items.filter({ (item) -> Bool in
                return item.title.contains(string)
            })
        }
        
        super.init()

        select.withLatestFrom(dataDidReload) { (indexPath:IndexPath, items:[Titled]) in
            return items[indexPath.row]
        }.bind(to: fieldVM.variable).disposed(by: disposeBag)
    }
}

