//
//  GraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EasyPeasy

class GraphVC<VM:GraphVM>: BaseTableVC <VM> {

    let errorLabel = UILabel()
    let errorContainer = UIView()

    init(_ viewModel: VM) {
        super.init(viewModel, style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        refreshControl = UIRefreshControl()
        setUpErrorLabel()

        super.viewDidLoad()

        tableView.register(EntryCell.self, forCellReuseIdentifier: EntryCell.classString)
        tableView.register(GraphHeader.self, forHeaderFooterViewReuseIdentifier: GraphHeader.classString)
    }

    func setUpErrorLabel() {
        errorContainer.backgroundColor = UIColor.white
        errorContainer.addSubview(errorLabel)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = UIColor.sdBrownishGrey
        errorLabel.easy.layout(Edges(10).with(.high))
    }

    override func bindViewModel() {
        super.bindViewModel()

        refreshControl!.rx.controlEvent(.valueChanged).asDriver()
            .do(onNext:{ [weak self] () in
                self?.tableView.tableHeaderView = nil
            })
            .drive(viewModel.refresh).disposed(by: disposeBag)

        viewModel.errorMessages.drive(onNext: { [weak self] (message) in
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
    }

    //MARK: Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(GraphHeader.self)) as! GraphHeader
        header.textLabel?.isHidden = true
        header.titleLabel.text = viewModel.title(for:section)
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(EntryCell.self)) ?? EntryCell()) as! EntryCell
        setUp(cell, at: indexPath)
        return cell
    }

    func setUp(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! EntryCell
        let (entry, date) = viewModel.entry(at: indexPath)
        if let entry = entry {
            cell.map(entry, maxRoundsCount:viewModel.maxCount(for: indexPath.section))
        }
        else {
            cell.clear(date)
        }
    }
}
