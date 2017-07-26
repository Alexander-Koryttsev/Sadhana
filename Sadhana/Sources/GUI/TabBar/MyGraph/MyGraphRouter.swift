//
//  MyGraphRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class MyGraphRouter : EditingRouter {
    weak var parent : MainTabBarRouter?

    func initialVC() -> UIViewController {
        return NavigationVC(rootViewController: MyGraphVC(MyGraphVM(self)))
    }

    func showSadhanaEditing(date: Date) {
        self.parent?.showSadhanaEditing(date: date)
    }

    func hideSadhanaEditing() {
        self.parent?.hideSadhanaEditing()
    }
}
