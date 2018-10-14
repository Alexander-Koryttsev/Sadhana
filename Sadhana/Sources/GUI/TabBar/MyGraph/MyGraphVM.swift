//
//  MyGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



import CoreData


class MyGraphVM: LocalGraphVM {
    private unowned let router: MyGraphRouter
    
    override var shouldShowHeader: Bool {
        return false
    }

    init(_ router: MyGraphRouter) {
        self.router = router

        super.init(Main.service.currentUser!)

        Remote.service.loadProfile(Local.defaults.userID!)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{ (profile) in
                Main.service.currentUser!.map(profile: profile)
                Local.service.viewContext.saveHandled()
            }).disposed(by: disposeBag)
    }

    override func syncEntries() -> Observable<Bool> {
        return Main.service.sendEntries()
                .track(self.errors)
                .concat(super.syncEntries())
    }
    
    override func select(_ indexPath: IndexPath) {
        self.router.showSadhanaEditing(date: self.date(at: indexPath))
    }

    @objc func showSettings() {
        router.showSettings()
    }
}
