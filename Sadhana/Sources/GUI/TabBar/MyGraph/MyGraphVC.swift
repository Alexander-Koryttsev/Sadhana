//
//  MyGraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/13/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



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

    override func tabBarItemAction() {
        if  tableView.numberOfSections > 0,
            tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: true)
        }
    }
}
