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

    let editingButton = UIFactory.editingButton

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEditingButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let items = tabBar.items, items.count == 2 {
            let offset = CGFloat(16)
            let leftItem = tabBar.items?.first!
            leftItem?.titlePositionAdjustment = UIOffset(horizontal: -1 * offset, vertical: 0)
            let rightItem = tabBar.items?.last!
            rightItem?.titlePositionAdjustment = UIOffset(horizontal: offset, vertical: 0)
        }

        tabBar.bringSubview(toFront: editingButton)
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        tabBar.isHidden = (viewControllers?.count ?? 0) < 2
    }

    private func setUpEditingButton() {
        tabBar.addSubview(editingButton)
        editingButton <- [
            CenterX(),
            Size(editingButton.bounds.size),
            Bottom(5)
        ]
        editingButton.addTarget(viewModel, action:#selector(MainTabBarVM.addEntry), for: .touchUpInside)
    }
}
