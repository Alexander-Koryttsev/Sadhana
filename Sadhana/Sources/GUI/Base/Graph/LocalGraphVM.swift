//
//  LocalGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 2/19/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//


class LocalGraphVM : GraphVM {
    let user : ManagedUser
    
    init(_ user:ManagedUser) {
        self.user = user
        
        super.init(user)

        refresh.flatMap { [unowned self] _ in
            return self.syncEntries()
        }   .subscribe()
            .disposed(by: disposeBag)
    }

    func syncEntries() -> Observable<Bool> {
        return Main.service.loadEntries(for: user)
            .do(onNext: {[weak self] _ in
                self?.reloadData()
                self?.dataDidReload.onNext(())
            })
            .track(self.errors)
            .track(self.pageRunning, index: 0)
            .asBoolNoErrorObservable()
    }
    
    override func reloadData() {
        clearData()
    }
    
    override func entries(for monthDate:LocalDate) -> [LocalDate : Entry] {
        var month = entries[monthDate]
        if month == nil {
            month = [LocalDate: Entry]()
            Local.service.viewContext.fetchEntries(by: monthDate, userID: user.ID).forEach({ (entry) in
                month![entry.localDate] = entry
            })
            
            entries[monthDate] = month!
        }
        return month!
    }
    
    override func entry(at indexPath:IndexPath) -> (Entry?, LocalDate) {
        let date = self.date(at:indexPath)
        var month = entries(for: date.trimDay)
        
        return (month[date], date)
    }
}
