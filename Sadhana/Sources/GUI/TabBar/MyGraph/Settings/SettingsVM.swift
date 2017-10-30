//
//  SettingsVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 10/5/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SettingsVM : BaseVM {

    let router : MyGraphRouter

    init(_ router: MyGraphRouter) {
        self.router = router
        super.init()
    }
    
}

struct SettingsSectionVM {
    let title : String
    let items : [SettingItemVM]
}

struct SettingItemVM {
    let title : String

}

struct SettingsSwitchItemVM {

}
