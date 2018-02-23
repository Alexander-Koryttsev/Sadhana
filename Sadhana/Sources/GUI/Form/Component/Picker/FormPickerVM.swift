//
//  FormPickerVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/5/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//





class FormPickerVM: BaseTableVM {
    let title : String
    let search = Variable("")
    let select = PublishSubject<IndexPath>()
    private(set) var dataDidReload : Driver<[Titled]>
    let refresh = PublishSubject<Void>()
    let activity = ActivityIndicator()

    init<T:Titled>(fieldVM: PickerFieldVM, load:Single<[T]>? = nil, searchSelector: ((String?) -> Single<[T]>)? = nil) {
        self.title = fieldVM.key
        
        dataDidReload = Driver.of([])
        super.init()

        if let searchSelector = searchSelector {
            let driverCombined = Driver.combineLatest(refresh.asDriver(onErrorJustReturn: ()), search.asDriver().debounce(0.5)) { (_, string) -> String in
                return string
            }
            
            dataDidReload = driverCombined.flatMap { [unowned self] (string) -> Driver<[Titled]> in
                    return searchSelector(string)
                        .track(self.errors)
                        .track(self.activity)
                        .map({ (items) -> [Titled] in
                            return items
                        })
                        .asDriver(onErrorJustReturn: [])
            }
        }
        else {
            guard let load = load else {
                fatalError("Load signal is nil")
            }
            let loader = refresh.asDriver(onErrorJustReturn: ()).flatMap { [unowned self] _ in
                return load
                    .track(self.activity)
                    .track(self.errors)
                    .asDriver(onErrorJustReturn: [])
            }
            
            dataDidReload = Driver.combineLatest(loader, search.asDriver()) { (items, string) -> [Titled] in
                if string.count == 0 {
                    return items
                }
                return items.filter({ (item) -> Bool in
                    return item.title.contains(string)
                })
            }
        }

        select.withLatestFrom(dataDidReload) { (indexPath:IndexPath, items:[Titled]) in
            return items[indexPath.row]
        }.bind(to: fieldVM.variable).disposed(by: disposeBag)
    }
}

