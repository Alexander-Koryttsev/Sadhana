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

    let errorLabel = UILabel()
    let errorContainer = UIView()

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout".localized, style:.plain, target:nil, action:nil)
        refreshControl = UIRefreshControl()
        setUpErrorLabel()

        super.viewDidLoad()

        tabBarItem = UITabBarItem(title: title, image:UIImage(named:"tab-bar-icon-my"), tag:0)
        tableView.register(EntryCell.self, forCellReuseIdentifier: NSStringFromClass(EntryCell.self))
        tableView.register(GraphHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(GraphHeader.self))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "My Graph", contentType: nil, contentId: nil, customAttributes: nil)
    }

    func setUpErrorLabel() {
        errorContainer.backgroundColor = UIColor.white
        errorContainer.addSubview(errorLabel)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = UIColor.sdBrownishGrey
        errorLabel <- Edges(10).with(.high)
    }

    override func bindViewModel() {
        super.bindViewModel()
        refreshControl!.rx.controlEvent(.valueChanged).asDriver()
            .do(onNext:{ [weak self] () in
                self?.tableView.tableHeaderView = nil
            })
            .drive(viewModel.refresh).disposed(by: disposeBag)

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

        viewModel.errorMessagesUI.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (message) in
                self?.errorLabel.text = message
                //TODO: fix layout bug
                //TODO: move to the extension
                //set the tableHeaderView so that the required height can be determined
                self?.tableView.tableHeaderView = self?.errorContainer;
                self?.errorContainer.setNeedsLayout()
                self?.errorContainer.layoutIfNeeded()
                let height = self?.errorContainer.systemLayoutSizeFitting(CGSize(width:UIScreen.main.bounds.size.width, height:CGFloat.greatestFiniteMagnitude)).height

                //update the header's frame and set it again
                var headerFrame = self?.errorContainer.frame;
                headerFrame?.size.height = height ?? 0 + 4;
                self?.errorContainer.frame = headerFrame ?? CGRect();
                self?.tableView.tableHeaderView = self?.errorContainer;
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
