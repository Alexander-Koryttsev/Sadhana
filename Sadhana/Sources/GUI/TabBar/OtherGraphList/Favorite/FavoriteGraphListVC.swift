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
import Crashlytics
import EasyPeasy

class FavoriteGraphListVC : GraphListVC<FavoriteGraphListVM> {
    override var title:String? {
        get {
            return "favorites".localized
        }
        set {}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentView(withName: "Favorite Graph List", contentType: nil, contentId: nil, customAttributes: nil)
        
        let label = UILabel()
        label.text = "letsPrayForFavorites".localized
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let container = UIView()
        container.backgroundColor = .white
        container.addSubview(label)
        
        label <- Edges(10)
        
        tableView.superview!.addSubview(container)
        container <- Edges()
    }
}
