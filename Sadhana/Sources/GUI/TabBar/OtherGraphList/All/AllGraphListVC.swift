//
//  AllGraphListVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa

import EasyPeasy
import Crashlytics

class AllGraphListVC: GraphListVC<AllGraphListVM> {

    let searchBar = UISearchBar()
    let searchBarHeight : CGFloat = 46.0
    var observer : NSObjectProtocol?

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
        searchBar.easy.layout([
            Left(2),
            Bottom(),
            Right(2),
            Top(iOS(11) ? 10 : 2)
        ])
        tableView.tableHeaderView = searchContainer
        viewModel.refresh.onNext(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if base.firstAppearing {
            tableView.contentOffset = CGPoint(x:0, y: (searchBarHeight - (navigationController?.navigationBar.bounds.size.height)! - UIApplication.shared.statusBarFrame.size.height))

            let searchField : UITextField = searchBar.value(forKey: "_searchField") as! UITextField
            searchField.layer.masksToBounds = true
            searchField.layer.cornerRadius = searchField.bounds.size.height / 2.0
            searchField.borderStyle = .none
            searchField.backgroundColor = .sdPaleGrey
        }
        
        Answers.logContentView(withName: "All Graph List", contentType: nil, contentId: nil, customAttributes: nil)

        NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground).map { [unowned self] _ in
            if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
            }
            return
        }.bind(to: viewModel.refresh).disposed(by: viewModel.disappearBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func bindViewModel() {
        super.bindViewModel()
        let dataDidReloadDriver = viewModel.dataDidReload.asDriver(onErrorJustReturn: ())

        let isRefreshControlAnimating = Driver.merge(viewModel.refreshDriver.map { true }, viewModel.firstPageRunning.filter { !$0 }.map { _ in false })
        isRefreshControlAnimating.drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)

        refreshControl?.rx.controlEvent(.valueChanged).asDriver().drive(viewModel.refresh).disposed(by: disposeBag)

        setUpDefaultActivityIndicator(with: viewModel.pageRunning.isActiveDriver)

        dataDidReloadDriver.drive(onNext: { [unowned self] () in
            self.reloadData()
        }).disposed(by: disposeBag)

        viewModel.pageDidUpdate.asDriver(onErrorJustReturn: 0).drive(onNext: { [unowned self] (section) in
            if let paths = self.tableView.indexPathsForVisibleRows {
                for path in paths {
                    if path.section == section {
                        if let cell = self.tableView.cellForRow(at: path) {
                            self.setUp(cell, at: path)
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected.asDriver().drive(viewModel.select).disposed(by: disposeBag)

        searchBar.rx.textRequired.asDriver().drive(viewModel.search).disposed(by: disposeBag)

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath) as! GraphCell
        setUp(cell, at: indexPath)
        return cell
    }

    func setUp(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! GraphCell
        if let entry = viewModel.entry(at: indexPath) {
            cell.map(entry: entry, name: entry.userName, avatarURL:entry.avatarURL)
        }
        else {
            cell.clear()
        }
    }


}
