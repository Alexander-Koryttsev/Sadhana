//
//  OtherGraphRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



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
            let vm : GraphVM
            if let user = Local.service.viewContext.fetchUser(for: info.userID) {
                vm = LocalGraphVM(user)
            }
            else {
                vm = RemoteGraphVM(info)
            }
            
            let vc = GraphVC(vm)
            navigationVC.pushViewController(vc, animated: true)
        }
    }
}
