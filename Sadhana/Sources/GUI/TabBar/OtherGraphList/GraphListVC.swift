//
//  GraphListVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa


class GraphListVC<VM:GraphListVM> : BaseTableVC<VM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(GraphCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 64
    }
}
