//
//  FavoriteGraphListVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FavoriteGraphListVC : GraphListVC<FavoriteGraphListVM> {
    override var title:String? {
        get {
            return "favorites".localized
        }
        set {}
    }
}
