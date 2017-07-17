//
//  MainTabBarRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class MainTabBarRouter {

    let mySadhanaRouter = MySadhanaRouter()

    func initialVC() -> UIViewController {

        let tabBarVC = MainTabBarVC(MainTabBarVM(self))
        tabBarVC.setViewControllers([mySadhanaRouter.initialVC()], animated: false)

        return tabBarVC
    }
}

