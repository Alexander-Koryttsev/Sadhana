//
//  MyGraphVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import RxCocoa

import CoreData
import Foundation

class MyGraphVM: LocalGraphVM {
    private unowned let router: MyGraphRouter
    
    override var shouldShowHeader: Bool {
        return false
    }

    init(_ router: MyGraphRouter) {
        self.router = router

        super.init(Main.service.currentUser!)
    }
    
    override func select(_ indexPath: IndexPath) {
        self.router.showSadhanaEditing(date: self.date(at: indexPath))
    }

    @objc func showSettings() {
        router.showSettings()
    }
}
