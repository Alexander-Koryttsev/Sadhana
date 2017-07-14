//
//  BaseVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/12/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class BaseVC<VM>: UIViewController {
    let viewModel:VM
    
    init(viewModel:VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() -> Void {
        preconditionFailure("This method must be overridden")
    }
}


class BaseTableVC<VM>: UITableViewController {
    let viewModel:VM
    
    init(viewModel:VM, style:UITableViewStyle = .plain) {
        self.viewModel = viewModel
        super.init(style: style)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() -> Void {
        preconditionFailure("This method must be overridden")
    }
}
