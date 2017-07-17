//
//  MySadhanaVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/13/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import CoreData

class MySadhanaVC: BaseFetchedResultsVC<MySadhanaVM> {

    override var title:String? {
        get { return "My Sadhana" }
        set {}
    }

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style:.plain, target:self, action:#selector(logOut(sender:)))
        viewModel.frc.delegate = self;
        refreshControl = UIRefreshControl()
        super.viewDidLoad()
    }

    func logOut(sender: UIBarButtonItem) {
        RootRouter.shared?.logOut()
    }

    override func bindViewModel() {
        super.bindViewModel()
        _ = refreshControl!.rx.controlEvent(.valueChanged).asDriver().drive(viewModel.refresh)
        _ = viewModel.running.asDriver().drive(refreshControl!.rx.isRefreshing)
    }

    //MARK: Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.frc.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.frc.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = viewModel.frc.sections?[section] else { return nil }
        return section.name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .value2, reuseIdentifier: "Cell")
        let entry = viewModel.frc.object(at: indexPath)
        cell.textLabel?.text = entry.date.description
        cell.detailTextLabel?.text = "\(entry.japaCount7_30), \(entry.japaCount10), \(entry.japaCount18), \(entry.japaCount24)"
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  indexPath.section == (viewModel.frc.sections?.count)! - 1 &&
            indexPath.row > (viewModel.frc.sections?.last?.numberOfObjects)! - 3 {
            viewModel.endOfList.onNext()
        }
    }
}
