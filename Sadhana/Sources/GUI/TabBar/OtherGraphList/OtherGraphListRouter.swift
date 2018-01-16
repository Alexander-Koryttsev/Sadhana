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
    private var navigationVC = NavigationVC()

    var initialVC : UIViewController {
        let allVC = AllGraphListVC(AllGraphListVM(self))
        let favoriteVC = FavoriteGraphListVC(FavoriteGraphListVM(self))
        let container = OtherGraphListContainerVC([allVC, favoriteVC])
        navigationVC.viewControllers = [container]

        return navigationVC
    }

    func showGraph(of info:UserBriefInfo) {
        if info.userID == Local.defaults.userID {
            parent?.showMyGraph()
        }
        else {
            let vm = OtherGraphVM(info)
            let vc = OtherGraphVC(vm)
            navigationVC.pushViewController(vc, animated: true)
        }
    }
}
