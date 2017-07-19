//
//  MainTabBarVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import EasyPeasy

class MainTabBarVC : BaseTabBarVC<MainTabBarVM> {
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        tabBar.isHidden = (viewControllers?.count ?? 0) < 2
    }

    
}
