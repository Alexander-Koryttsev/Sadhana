//
//  MyGraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/13/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class MyGraphVC: GraphVC<MyGraphVM> {
    
    override var title:String? {
        get { return "myGraph".localized }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem = UITabBarItem(title: title, image:UIImage(named:"tab-bar-icon-my"), tag:0)
        tableView.allowsSelection = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings-button"), style: .plain, target: viewModel, action: #selector(MyGraphVM.showSettings))
    }
}
