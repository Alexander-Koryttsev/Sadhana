//
//  MySadhanaRouter.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/14/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class MySadhanaRouter {

    func initialVC() -> UIViewController {
        return NavigationVC(rootViewController: MySadhanaVC(MySadhanaVM(self)))
    }

}
