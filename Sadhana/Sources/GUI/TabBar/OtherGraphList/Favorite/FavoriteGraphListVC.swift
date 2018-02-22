//
//  FavoriteGraphListVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa

import Crashlytics
import EasyPeasy

class FavoriteGraphListVC : GraphListVC<FavoriteGraphListVM> {
    
    let emptyView = UIView()
    var emptyViewSuperview : UIView?
    
    override var title:String? {
        get {
            return "favorites".localized
        }
        set {}
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.contentInset = UIEdgeInsetsMake(TopInset, 0, 50, 0)
        
        let label = UILabel()
        //TODO: Localize
        label.text = "No Favorites"
        label.numberOfLines = 0
        label.textAlignment = .center
    
        emptyView.backgroundColor = .white
        emptyView.isHidden = true
        emptyView.isUserInteractionEnabled = false
        emptyView.addSubview(label)
        
        label.easy.layout(Edges(10))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        setUpEmptyView()
        viewModel.refresh.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentView(withName: "Favorite Graph List", contentType: nil, contentId: nil, customAttributes: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpEmptyView()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        viewModel.change.subscribe(onNext: { [unowned self] (type, indexPath) in
            self.tableView.beginUpdates()

            switch type {
                case .insert: self.tableView.insertRows(at: [ indexPath ], with: .automatic); break
                case .update: self.tableView.reloadRows(at: [ indexPath ], with: .none); break
                case .delete: self.tableView.deleteRows(at: [ indexPath ], with: .left); break
            }

            self.tableView.endUpdates()
            self.updateEmptyView()
        }).disposed(by: disposeBag)

        refreshControl!.rx.controlEvent(.valueChanged).bind(to: viewModel.refresh).disposed(by: disposeBag)
        viewModel.activityIndicator.asDriver().filter { !$0 } .drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)

        setUpDefaultActivityIndicator(with: viewModel.activityIndicator.asDriver())
    }

    func setUpEmptyView() {
        if emptyView.superview == nil {
            if emptyViewSuperview == nil {
                emptyViewSuperview = tableView.superview
            }

            if let emptyViewSuperview = emptyViewSuperview {
                emptyViewSuperview.addSubview(emptyView)
                emptyView.easy.layout(Edges())
            }
        }
        updateEmptyView()
    }
    
    func updateEmptyView() {
        emptyView.superview?.bringSubview(toFront: emptyView)
        emptyView.isHidden = viewModel.numberOfRows(in: 0) > 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath) as! GraphCell
        let (user, entry) = viewModel.userAndEntry(at: indexPath)

        cell.map(entry: entry, name: user.name, avatarURL: user.avatarURL)
        cell.shouldIndentWhileEditing = false
        return cell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.move(sourceIndexPath, to:destinationIndexPath)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
}
