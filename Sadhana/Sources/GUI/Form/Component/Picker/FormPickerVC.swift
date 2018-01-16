//
//  FormPickerVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/5/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy

class FormPickerVC: BaseTableVC<FormPickerVM> {

    let searchBar = UISearchBar()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        super.viewDidLoad()

        let searchContainer = UIView(frame:CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:46))
        searchContainer.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextPositionAdjustment = UIOffsetMake(10.0, 0.0)
        searchBar.easy.layout([
            Left(2),
            Bottom(),
            Right(2),
            Top(iOS(11) ? 10 : 2)
            ])

        tableView.tableHeaderView = searchContainer
        tableView.keyboardDismissMode = .interactive

    }

    override func bindViewModel() {
        super.bindViewModel()

        searchBar.rx.textRequired.bind(to: viewModel.search).disposed(by: disposeBag)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        viewModel.dataDidReload.do(onNext:{ [unowned self] _ in self.activityIndicator.stopAnimating() }).drive(tableView.rx.items(cellIdentifier: "Cell")) {
            (index, item: Titled, cell) in
            cell.textLabel?.text = item.title
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }.disposed(by: disposeBag)

        tableView.rx.itemSelected.bind(to:viewModel.select).disposed(by: disposeBag)

        title = viewModel.title
    }

}

