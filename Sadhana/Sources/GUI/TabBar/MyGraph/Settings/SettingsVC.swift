//
//  SettingsVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class SettingsVC : BaseTableVC <SettingsVM> {

    init(_ viewModel:VM) {
        super.init(viewModel, style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
