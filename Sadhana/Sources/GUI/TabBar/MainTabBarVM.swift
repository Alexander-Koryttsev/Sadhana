//
//  MainTabBarVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation

class MainTabBarVM: BaseVM {
    private unowned let router : MainTabBarRouter

    init(_ router : MainTabBarRouter) {
        self.router = router
    }

    @objc func addEntry() {
        router.showSadhanaEditing()
    }
}
