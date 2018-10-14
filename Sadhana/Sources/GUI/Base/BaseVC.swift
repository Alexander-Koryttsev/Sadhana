//
//  BaseVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/12/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import CoreData

import EasyPeasy


class ViewControllerBaseVars<VM:BaseVM> {
    var viewModel:VM
    var guideView:GuideView? = nil
    var firstAppearing = true
    var hasGuide = false
    var defaultErrorMessagingEnabled = true
    
    init(_ viewModel:VM) {
        self.viewModel = viewModel
    }
}

protocol ViewController {
    func tabBarItemAction()
}

extension ViewController {

}

protocol ViewControllerProtected : ViewController where Self : UIViewController  {
    associatedtype VM:BaseVM
    var base : ViewControllerBaseVars<VM> { get set }

    var viewModel:VM { get }

    func createGuide()
    func alertDidDismiss()
}

extension ViewControllerProtected {
    var disposeBag:DisposeBag {
        return viewModel.disposeBag
    }
    
    var viewModel:VM {
        return base.viewModel
    }

    var navigationVC: NavigationVC? {
        return navigationController as? NavigationVC
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

        if base.defaultErrorMessagingEnabled {
            viewModel.messagesUI.throttle(2).drive(onNext:{ (message) in
                if let window = AppDelegate.shared.window {
                    let container = BlurView()
                    let label = UILabel()
                    label.text = message
                    label.textColor = .black
                    label.textAlignment = .center
                    label.font = UIFont.systemFont(ofSize: 12)
                    label.numberOfLines = 2
                    container.contentView.addSubview(label)
                    label.easy.layout([Left(14), Bottom(5), Right(14), Height(34)])
                    window.addSubview(container)
                    let height = TopInset + 1
                    container.easy.layout([Height(height), Top(-height), Left(), Right()])
                    window.layoutIfNeeded()
                    UIView.animate(withDuration: 0.25, animations: {
                        container.easy.layout(Top())
                        window.layoutIfNeeded()
                    })
                    UIView.animate(withDuration: 0.25, delay: Double(message.count)/20.0, options: [], animations: {
                        container.easy.layout(Top(-height))
                        window.layoutIfNeeded()
                    }, completion: { _ in
                        container.removeFromSuperview()
                    })
                }
            }).disposed(by: disposeBag)
        }
    }

    fileprivate func baseViewDidAppear(_ animated: Bool) {
         if base.hasGuide, !Local.defaults.isGuideShown(self) {
            createGuide()
            if let guide = base.guideView {
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
        
        DispatchQueue.main.async { [unowned self] in
            self.base.firstAppearing = false
        }
    }

    fileprivate func baseViewDidDisappear() {
        viewModel.disappearBag = DisposeBag()
        hideGuide(animated: false)
    }

    func hideGuide(animated:Bool) {
        if let guide = base.guideView {
            if animated {
                UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    guide.removeFromSuperview()
                }, completion: { _ in
                    self.base.guideView = nil
                })
            }
            else {
                guide.removeFromSuperview()
                base.guideView = nil
            }
        }
    }

    func setUpDefaultActivityIndicator(with driver: Driver<Bool>) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true
        let item = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = item
        driver.drive(activityIndicator.rx.isAnimating).disposed(by: disposeBag)
    }
}

class BaseVC<VM:BaseVM>: UIViewController, ViewControllerProtected {
    var base: ViewControllerBaseVars<VM>

    init(_ viewModel:VM) {
        self.base = ViewControllerBaseVars(viewModel)
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

    func alertDidDismiss() {

    }

    func tabBarItemAction() {

    }
}

class BaseTableVC<VM:BaseTableVM>: UITableViewController, ViewControllerProtected {
    var base: ViewControllerBaseVars<VM>
    
    init(_ viewModel:VM, style:UITableViewStyle = .plain) {
        self.base = ViewControllerBaseVars(viewModel)
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

    func tabBarItemAction() {

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(indexPath)
    }

    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let configuration = viewModel.trailingSwipeActionsConfiguration(forRowAt:indexPath)
        return configuration
    }
}

class BaseTabBarVC<VM:BaseVM>: UITabBarController, ViewControllerProtected {
    var base: ViewControllerBaseVars<VM>
    
    init(_ viewModel:VM) {
        self.base = ViewControllerBaseVars(viewModel)
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

    func alertDidDismiss() {

    }

    func tabBarItemAction() {

    }
}

