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

class BaseVC<VM:BaseVM>: UIViewController, ViewController {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseViewDidDisappear()
    }
    
    func bindViewModel() -> Void {
        baseBindViewModel()
    }
}

class BaseTableVC<VM:BaseVM>: UITableViewController, ViewController {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseViewDidDisappear()
    }

    func reloadData() {
        self.tableView.reloadData()
    }

    func bindViewModel() -> Void {
        baseBindViewModel()
    }
}

class BaseTabBarVC<VM:BaseVM>: UITabBarController, ViewController {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseViewDidDisappear()
    }

    func bindViewModel() -> Void {
        baseBindViewModel()
    }
}

class BaseFetchedResultsVC<VM:BaseVM>: BaseTableVC<VM>, NSFetchedResultsControllerDelegate {

    var updatedSections = IndexSet()
    var insertedSections = IndexSet()
    var oldSectionsCount = 0

/*
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        log("change(\(type.rawValue)) rows")
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
        //log("change(\(type.rawValue)) section \(sectionIndex)")
        switch type {
        case .insert:  /* tableView.insertSections(IndexSet(integer:sectionIndex), with: .none);*/ insertedSections.insert(sectionIndex); break
       // case .delete:   tableView.deleteSections(IndexSet(integer:sectionIndex), with: .none); break
        //case .move:     log("what should I do with move section?")                         ; break
        case .update:   /*tableView.reloadSections(IndexSet(integer:sectionIndex), with: .none);*/ updatedSections.insert(sectionIndex); break
        default: break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       // log("will change (now sections \(tableView.numberOfSections))")
        oldSectionsCount = tableView.numberOfSections
        updatedSections.removeAll()
        insertedSections.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //log("did change")
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

protocol ViewController {
    associatedtype VM:BaseVM
    var viewModel:VM { get }
}

extension ViewController where Self : UIViewController {
    var disposeBag:DisposeBag {
        get {
            return viewModel.disposeBag
        }
    }

    fileprivate final func baseBindViewModel() {
        viewModel.alerts.subscribe(onNext: { [weak self] (alert) in

            alert.add(completion: { 
                RootRouter.shared?.setPlusButton(hidden:false, animated:true)
            })

            self?.present(alert.uiAlertController, animated: true)
            RootRouter.shared?.setPlusButton(hidden:true, animated:true)
        }).disposed(by: disposeBag)
    }
    
    fileprivate final func baseViewDidDisappear() {
        viewModel.disappearBag = DisposeBag()
    }
}


class Alert {
    var title : String?
    var message : String?
    var style = UIAlertControllerStyle.actionSheet
    private var actions = [Action]()
    private var completions = [Block]()

    var uiAlertController : UIAlertController {
        get {
            let alert = UIAlertController(title: title, message: message, preferredStyle: style)
            for action in actions {
                alert.addAction(action.uiAlertAction(completions: completions))
            }
            return alert
        }
    }

    func add(action title: String, style: UIAlertActionStyle? = .default, handler: Block?) {
        actions.append(Action(title: title, style: style!, handler: handler))
    }

    func addCancelAction() {
        add(action:"cancel".localized, style: .cancel, handler: nil)
    }

    func add(completion: @escaping Block) {
        completions.append(completion)
    }

    struct Action {
        var title : String
        var style = UIAlertActionStyle.default
        var handler : Block?

        func uiAlertAction(completions:[Block]) -> UIAlertAction {
            return UIAlertAction(title: title, style: style, handler: { (_) in
                self.handler?()
                for completion in completions {
                    completion()
                }
            })
        }
    }
}

