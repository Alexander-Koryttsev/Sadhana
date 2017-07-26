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

class MyGraphVC: BaseFetchedResultsVC<MyGraphVM> {

    override var title:String? {
        get { return "Мой график" }
        set {}
    }

    let errorLabel = UILabel()
    let errorContainer = UIView()
    var maxCounts = [Int : Int16]()

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style:.plain, target:self, action:#selector(logOut(sender:)))
        viewModel.frc.delegate = self;
        refreshControl = UIRefreshControl()
        setUpErrorLabel()

        super.viewDidLoad()

        tabBarItem = UITabBarItem(title: title, image:UIImage(named:"tab-bar-icon-my"), tag:0)
        tableView.register(EntryCell.self, forCellReuseIdentifier: NSStringFromClass(EntryCell.self))
        tableView.register(GraphHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(GraphHeader.self))
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

        viewModel.running.asDriver()
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
        maxCounts.removeAll()
        super.reloadData()
    }

    override func sectionsDidUpdate(_ sections:IndexSet) {
        super.sectionsDidUpdate(sections)
        maxCounts.removeAll()
    }

    func maxCount(for section:Int) -> Int16 {

        if let cachedCount = maxCounts[section] {
            return cachedCount
        }
        let maxCount = viewModel.frc.sections![section].objects?.reduce(16, { (result, entry) -> Int16 in
            let sum = (entry as! SadhanaEntry).japaSum
            return sum > result ? sum : result
        })
        maxCounts[section] = maxCount
        return maxCount!
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
        return (section.objects?.first! as! SadhanaEntry).date.monthMedium
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(GraphHeader.self)) as! GraphHeader
        header.textLabel?.isHidden = true
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(EntryCell.self)) ?? EntryCell()) as! EntryCell

        let entry = viewModel.frc.object(at: indexPath)
        cell.map(entry, maxRoundsCount:self.maxCount(for: indexPath.section))

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  indexPath.section == (viewModel.frc.sections?.count)! - 1 &&
            indexPath.row > (viewModel.frc.sections?.last?.numberOfObjects)! - 3 {
            viewModel.endOfList.onNext()
        }
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
