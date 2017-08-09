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

class MyGraphVC: GraphVC<MyGraphVM> {
    override var title:String? {
        get { return "myGraph".localized }
        set {}
    }

    let errorLabel = UILabel()
    let errorContainer = UIView()

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout".localized, style:.plain, target:self, action:#selector(logOut(sender:)))
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

    func setUpErrorLabel() {
        errorContainer.backgroundColor = UIColor.white
        errorContainer.addSubview(errorLabel)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = UIColor.sdBrownishGrey
        errorLabel <- Edges(10)
    }

    func logOut(sender: UIBarButtonItem) {
        RootRouter.shared?.logOut()
    }

    override func bindViewModel() {
        super.bindViewModel()
        refreshControl!.rx.controlEvent(.valueChanged).asDriver()
            .do(onNext:{
                self.tableView.tableHeaderView = nil
            })
            .drive(viewModel.refresh).disposed(by: disposeBag)

        viewModel.running.asDriver().do(onNext:({[weak self] (running) in
            if !running {
                self?.reloadData()
            }
        }))
            .drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)

        viewModel.errorMessagesUI.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (message) in
                self.errorLabel.text = message
                //TODO: fix layout bug
                //TODO: move to the extension
                //set the tableHeaderView so that the required height can be determined
                self.tableView.tableHeaderView = self.errorContainer;
                self.errorContainer.setNeedsLayout()
                self.errorContainer.layoutIfNeeded()
                let height = self.errorContainer.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height

                //update the header's frame and set it again
                var headerFrame = self.errorContainer.frame;
                headerFrame.size.height = height;
                self.errorContainer.frame = headerFrame;
                self.tableView.tableHeaderView = self.errorContainer;
            }).disposed(by: disposeBag)
    }

    override func reloadData() {
        viewModel.reloadData()
        tableView.reloadData()
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
