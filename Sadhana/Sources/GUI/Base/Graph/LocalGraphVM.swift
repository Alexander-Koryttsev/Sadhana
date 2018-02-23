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
            return Main.service.loadEntries(for: user)
                .do(onSuccess: {[weak self] _ in
                    self?.reloadData()	
                    self?.dataDidReload.onNext(())
                })
                .track(self.errors)
                .track(self.pageRunning, index: 0)
                .asBoolObservable()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    override func reloadData() {
        clearData()
    }
    
    override func entries(for monthDate:Date) -> [Date : Entry] {
        var month = entries[monthDate]
        if month == nil {
            month = [Date: Entry]()
            Local.service.viewContext.fetchEntries(by: monthDate, userID: user.ID).forEach({ (entry) in
                month![entry.date] = entry
            })
            
            entries[monthDate] = month!
        }
        return month!
    }
    
    override func entry(at indexPath:IndexPath) -> (Entry?, Date) {
        let date = self.date(at:indexPath)
        var month = entries(for: date.trimmedDayAndTime)
        
        return (month[date], date)
    }
}
