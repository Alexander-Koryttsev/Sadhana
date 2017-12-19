//
//  FavoriteGraphListVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class FavoriteGraphListVM : GraphListVM {
    private unowned let router : OtherGraphListRouter

    init(_ router:OtherGraphListRouter) {
        self.router = router
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
