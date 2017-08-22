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

class AllGraphListVC: GraphListVC<AllGraphListVM> {

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
        viewModel.refresh.onNext()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func bindViewModel() {
        super.bindViewModel()

        refreshControl?.rx.controlEvent(.valueChanged).asDriver().drive(viewModel.refresh).disposed(by: disposeBag)
        viewModel.firstPageRunning.drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)

        viewModel.dataDidReload.asDriver(onErrorJustReturn: ()).drive(onNext: { [unowned self] () in
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
