//
//  NavigationVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/13/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


class NavigationVC: UINavigationController, ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tabBarItemAction() {
        if let vc = topViewController as? ViewController {
            vc.tabBarItemAction()
        }
    }
}
