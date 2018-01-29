//
//  EntryEditingVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

import RxCocoa

class EntryEditingVC : BaseTableVC<EntryEditingVM> {
    var cells = [FormCell]()

    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(iOS(11) ? 108 : 128, 0, 50, 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.row].height
    }

    override func bindViewModel() {
        super.bindViewModel()

        for field in viewModel.fields {
            cells.append(FormFactory.cell(for: field))
        }

        FormHelper.bind(cells: cells, endEditingAction: { [weak self] in
            self?.tableView.endEditing(true)
        }, disposeBag: disposeBag)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing {
            tableView.endEditing(true)
        }
    }
    
    func becomeActive() {
        for cell in cells {
            if !cell.isFilled {
                if let responisble = cell as? Responsible {
                    responisble.becomeActive.onNext(())
                }
                return
            }
        }
    }
}
