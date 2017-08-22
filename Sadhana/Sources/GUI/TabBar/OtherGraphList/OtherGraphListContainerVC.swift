//
//  OtherGraphListContainerVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import EasyPeasy

class OtherGraphListContainerVC : UIViewController {
    let viewControllers : [UIViewController]
    let segmentedControl : UISegmentedControl

    private var currentVC : UIViewController {
        willSet {
            currentVC.willMove(toParentViewController: nil)
            currentVC.removeFromParentViewController()
            currentVC.view.removeFromSuperview()
        }

        didSet {
            currentVC.willMove(toParentViewController: self)
            addChildViewController(currentVC)
            view.addSubview(currentVC.view)
            currentVC.view <- Edges()
        }
    }

    let disposeBag = DisposeBag()

    override var title:String? {
        get {
            return "otherGraph".localized
        }
        set {}
    }

    init(_ viewControllers:[UIViewController]) {
        self.viewControllers = viewControllers
        segmentedControl = UISegmentedControl(items: viewControllers.map { $0.title! })
        segmentedControl.selectedSegmentIndex = 0
        currentVC = viewControllers.first!
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: title, image:#imageLiteral(resourceName: "tab-bar-icon-all"), tag:0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedControl

        segmentedControl.rx.selectedSegmentIndex.asDriver().distinctUntilChanged().drive(onNext:{ [unowned self] (index) in
            self.currentVC = self.viewControllers[index]
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
