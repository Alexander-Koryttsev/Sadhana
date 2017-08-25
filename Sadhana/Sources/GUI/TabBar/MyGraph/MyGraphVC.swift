//
//  MyGraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/13/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import EasyPeasy
import Crashlytics

class MyGraphVC: GraphVC<MyGraphVM> {
    override var title:String? {
        get { return "myGraph".localized }
        set {}
    }


    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout".localized, style:.plain, target:nil, action:nil)

        super.viewDidLoad()

        tabBarItem = UITabBarItem(title: title, image:UIImage(named:"tab-bar-icon-my"), tag:0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "My Graph", contentType: nil, contentId: nil, customAttributes: nil)
    }

    override func reloadData() {
        viewModel.reloadData()
        super.reloadData()
    }

    override func bindViewModel() {
        super.bindViewModel()
        

        viewModel.running.asDriver().do(onNext:({[weak self] (running) in
            if !running {
                self?.tableView.reloadData()
            }
        })) .drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)

        viewModel.updateSection.drive(onNext:{ [weak self] (section) in
            self?.tableView.beginUpdates()
            self?.tableView.reloadSections(NSIndexSet(index:section) as IndexSet, with: .fade)
            self?.tableView.endUpdates()
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected.asDriver().drive(viewModel.select).disposed(by: disposeBag)

        navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(viewModel.logOut).disposed(by: disposeBag)
    }
}


class GraphHeader: UITableViewHeaderFooterView {

    let bar = UINavigationBar()
    let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier ?? NSStringFromClass(GraphHeader.self))
        backgroundView = bar
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.sdBrownishGrey
        titleLabel <- Center()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
