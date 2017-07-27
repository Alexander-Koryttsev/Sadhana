//
//  BaseVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/12/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import Foundation

class BaseVC<VM:BaseVMProtocol>: UIViewController, BaseVCProtocol {
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

class BaseTableVC<VM:BaseVMProtocol>: UITableViewController, BaseVCProtocol {
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

    func reloadData() {
        self.tableView.reloadData()
    }

    func bindViewModel() -> Void {

    }
}

class BaseTabBarVC<VM:BaseVMProtocol>: UITabBarController, BaseVCProtocol {
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

class BaseFetchedResultsVC<VM:BaseVMProtocol>: BaseTableVC<VM>, NSFetchedResultsControllerDelegate {

    var updatedSections = IndexSet()
    var insertedSections = IndexSet()
    var oldSectionsCount = 0

/*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("change(\(type.rawValue)) rows")
        switch type {
        case .insert:   tableView.insertRows(at: [newIndexPath!], with: .none); break
        case .delete:   tableView.deleteRows(at: [indexPath!], with: .none)   ; break
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .none)
            tableView.insertRows(at: [newIndexPath!], with: .none)
            break
        case .update:   tableView.reloadRows(at: [indexPath!], with: .none)   ; break
        }
    }*/

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //print("change(\(type.rawValue)) section \(sectionIndex)")
        switch type {
        case .insert:  /* tableView.insertSections(IndexSet(integer:sectionIndex), with: .none);*/ insertedSections.insert(sectionIndex); break
       // case .delete:   tableView.deleteSections(IndexSet(integer:sectionIndex), with: .none); break
        //case .move:     print("what should I do with move section?")                         ; break
        case .update:   /*tableView.reloadSections(IndexSet(integer:sectionIndex), with: .none);*/ updatedSections.insert(sectionIndex); break
        default: break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       // print("will change (now sections \(tableView.numberOfSections))")
        oldSectionsCount = tableView.numberOfSections
        updatedSections.removeAll()
        insertedSections.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //print("did change")
       // reloadData()
/*
        if self.tableView.window != nil && self.oldSectionsCount + self.insertedSections.count == controller.sections?.count {
            self.tableView.beginUpdates()
            self.tableView.reloadSections(self.updatedSections, with: .none)
            self.tableView.insertSections(self.insertedSections, with: .none)
            self.tableView.endUpdates()
            if self.updatedSections.count > 0 {
                self.sectionsDidUpdate(self.updatedSections)
            }
        }
        else {*/
            self.reloadData()
      //  }
    }

    func sectionsDidUpdate(_ sections:IndexSet) {

    }
}

protocol BaseVCProtocol {
    associatedtype VM:BaseVMProtocol
    var viewModel:VM { get }
}

extension BaseVCProtocol {
    var disposeBag:DisposeBag { get {
        return self.viewModel.disposeBag
        }
    }

}

