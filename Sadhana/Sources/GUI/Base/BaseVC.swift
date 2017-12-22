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
import EasyPeasy

protocol ViewController {
    associatedtype VM:BaseVM
    var viewModel:VM { get }
    var hasGuide:Bool { get }
    var guideView:GuideView? { get set }

    func createGuide()
    func alertDidDismiss()
}

extension ViewController where Self : UIViewController {
    var disposeBag:DisposeBag {
        get {
            return viewModel.disposeBag
        }
    }

    fileprivate func baseBindViewModel() {
        viewModel.alerts.subscribe(onNext: { [weak self] (alert) in

            if iPad {
                alert.style = .alert
            }

            alert.add(completion: { [weak self] in
                RootRouter.shared?.setPlusButton(hidden:false, animated:true)
                self?.alertDidDismiss()
            })

            self?.present(alert.uiAlertController, animated: true)
            RootRouter.shared?.setPlusButton(hidden:true, animated:true)
        }).disposed(by: disposeBag)
    }

    fileprivate func baseViewDidAppear(_ animated: Bool) {
         if hasGuide, !Local.defaults.isGuideShown(self) {
            createGuide()
            if let guide = guideView {

                let closeButton = UIButton(type: .custom)
                closeButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
                closeButton.rx.tap.asDriver().drive(onNext: { [unowned self] () in
                    self.hideGuide(animated: true)
                }).disposed(by: disposeBag)
                view.addSubview(closeButton)
                closeButton.easy.layout([Right(8), Top(iPhoneX ? 42 : 8), Size(44)])
                guide.closeButton = closeButton

                if animated {
                    guide.isHidden = true
                    UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        guide.isHidden = false
                    }, completion: nil)
                }
              
                Local.defaults.set(guide: self, shown: true)
            }
         }
    }

    fileprivate func baseViewDidDisappear() {
        viewModel.disappearBag = DisposeBag()
        hideGuide(animated: false)
    }

    func hideGuide(animated:Bool) {
        if let guide = guideView {
            if animated {
                UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    guide.removeFromSuperview()
                }, completion: nil)
            }
            else {
                guide.removeFromSuperview()
            }
        }
    }

    func alertDidDismiss() {

    }
}

class BaseVC<VM:BaseVM>: UIViewController, ViewController {
    let viewModel:VM
    weak var guideView:GuideView?
    var hasGuide: Bool {
        return false
    }
    
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseViewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseViewDidDisappear()
    }
    
    func bindViewModel() -> Void {
        baseBindViewModel()
    }

    func createGuide() {

    }
}

class BaseTableVC<VM:BaseVM>: UITableViewController, ViewController {
    let viewModel:VM
    weak var guideView:GuideView?
    var hasGuide: Bool {
        return false
    }
    
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseViewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseViewDidDisappear()
    }

    func reloadData() {
        self.tableView.reloadData()
    }

    func bindViewModel() {
        baseBindViewModel()
    }

    func alertDidDismiss() {
        if clearsSelectionOnViewWillAppear, let selectedPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedPath, animated: true)
        }
    }

    func createGuide() {

    }
}

class BaseTabBarVC<VM:BaseVM>: UITabBarController, ViewController {
    let viewModel:VM
    weak var guideView:GuideView?
    var hasGuide: Bool {
        return false
    }

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseViewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseViewDidDisappear()
    }

    func bindViewModel() -> Void {
        baseBindViewModel()
    }

    func createGuide() {

    }
}



