//
//  AllGraphListVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import EasyPeasy

class AllGraphListVC: GraphListVC<AllGraphListVM> {

    let searchBar = UISearchBar()
    let searchBarHeight : CGFloat = 46.0
    var firstRun = true

    override var title:String? {
        get {
            return "all".localized
        }
        set {}
    }

    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        super.viewDidLoad()
        tableView.register(GraphCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag

        let searchContainer = UIView(frame:CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:searchBarHeight))
        searchContainer.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextPositionAdjustment = UIOffsetMake(10.0, 0.0)
        searchBar <- [
            Left(2),
            Bottom(),
            Right(2),
            Top(2)
        ]
        tableView.tableHeaderView = searchContainer
        viewModel.refresh.onNext()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firstRun {
            tableView.contentOffset = CGPoint(x:0, y: (searchBarHeight - (navigationController?.navigationBar.bounds.size.height)! - UIApplication.shared.statusBarFrame.size.height))

            let searchField : UITextField = searchBar.value(forKey: "_searchField") as! UITextField
            searchField.layer.masksToBounds = true
            searchField.layer.cornerRadius = searchField.bounds.size.height / 2.0
            searchField.borderStyle = .none
            searchField.backgroundColor = .sdPaleGrey
            firstRun = false
        }

    }

    override func bindViewModel() {
        super.bindViewModel()
        let dataDidReloadDriver = viewModel.dataDidReload.asDriver(onErrorJustReturn: ())

        refreshControl?.rx.controlEvent(.valueChanged).asDriver().drive(viewModel.refresh).disposed(by: disposeBag)

        dataDidReloadDriver.filter({ [unowned self] () -> Bool in
            return self.refreshControl!.isRefreshing
        }).drive(refreshControl!.rx.endRefreshing).disposed(by: disposeBag)

        viewModel.refreshDriver.drive(refreshControl!.rx.beginRefreshing).disposed(by: disposeBag)

        dataDidReloadDriver.drive(onNext: { [unowned self] () in
            self.reloadData()
        }).disposed(by: disposeBag)

        viewModel.pageDidUpdate.asDriver(onErrorJustReturn: 0).drive(onNext: { [unowned self] (section) in
            let visibleSections = self.tableView.indexPathsForVisibleRows?.map { $0.section }

            if let sections = visibleSections,
                sections.contains(section) {
                self.tableView.beginUpdates()
                self.tableView.reloadSections(IndexSet(integer:section), with: .fade)
                self.tableView.endUpdates()
            }
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected.asDriver().drive(viewModel.select).disposed(by: disposeBag)

        searchBar.rx.textRequired.asDriver().drive(viewModel.search).disposed(by: disposeBag)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.pagesCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entriesCount(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath) as! GraphCell
        if let entry = viewModel.entry(at: indexPath) {
            cell.map(entry: entry, name: entry.userName, avatarURL: URL(string: "http://vaishnava.wpengine.netdna-cdn.com/wp-content/uploads/2014/01/cropped-jagannath.jpg")!)
        }
        else {
            cell.clear()
        }

        return cell
    }

}
