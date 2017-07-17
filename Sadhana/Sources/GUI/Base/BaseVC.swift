//
//  BaseVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/12/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import CoreData

class BaseVC<VM>: UIViewController {
    let viewModel:VM
    
    init(_ viewModel:VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() -> Void {
        
    }
}

class BaseTableVC<VM>: UITableViewController {
    let viewModel:VM
    
    init(_ viewModel:VM, style:UITableViewStyle = .plain) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    func bindViewModel() -> Void {

    }
}

class BaseFetchedResultsVC<VM>: BaseTableVC<VM>, NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:   tableView.insertRows(at: [newIndexPath!], with: .none); break
        case .delete:   tableView.deleteRows(at: [indexPath!], with: .none)   ; break
        case .move:     tableView.moveRow(at: indexPath!, to: newIndexPath!)  ; break
        case .update:   tableView.reloadRows(at: [indexPath!], with: .none)   ; break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:   tableView.insertSections(IndexSet(integer:sectionIndex), with: .none); break
        case .delete:   tableView.deleteSections(IndexSet(integer:sectionIndex), with: .none); break
        case .move:     print("what should I do with move section?")                         ; break
        case .update:   tableView.reloadSections(IndexSet(integer:sectionIndex), with: .none); break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { tableView.beginUpdates() }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { tableView.endUpdates() }
}

class BaseTabBarVC<VM>: UITabBarController {
    let viewModel:VM

    init(_ viewModel:VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    func bindViewModel() -> Void {

    }
}

