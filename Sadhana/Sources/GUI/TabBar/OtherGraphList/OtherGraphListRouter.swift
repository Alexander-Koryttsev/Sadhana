//
//  OtherGraphRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class OtherGraphListRouter {
    weak var parent : MainTabBarRouter?
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

    func showGraphOfUser(with ID:Int32, name:String) {
        if ID == Local.defaults.userID {
            parent?.showMyGraph()
        }
        else {
            let vm = OtherGraphVM(ID, name: name)
            let vc = OtherGraphVC(vm)
            navigationVC.pushViewController(vc, animated: true)
        }
    }
}
