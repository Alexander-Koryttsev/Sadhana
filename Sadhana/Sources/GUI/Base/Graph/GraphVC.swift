//
//  GraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

class GraphVC<VM:GraphVM>: BaseTableVC <VM> {

    init(_ viewModel: VM) {
        super.init(viewModel, style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        let (entry, date) = viewModel.entry(at: indexPath)
        if let entry = entry {
            cell.map(entry, maxRoundsCount:viewModel.maxCount(for: indexPath.section))
        }
        else {
            cell.clear(date)
        }

        return cell
    }
}
