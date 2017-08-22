//
//  OtherGraphRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class OtherGraphListRouter {
    private var navigationVC = UINavigationController()



    var initialVC : UIViewController {
        get {

            let allVC = AllGraphListVC(AllGraphListVM(self))
            let favoriteVC = FavoriteGraphListVC(FavoriteGraphListVM(self))
            let container = OtherGraphListContainerVC([allVC, favoriteVC])
            navigationVC.viewControllers = [container]

            return navigationVC
        }
    }
}
