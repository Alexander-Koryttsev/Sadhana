//
//  EditingVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa

import EasyPeasy
import Crashlytics

class EditingVC: BaseVC<EditingVM>, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let topBar = UIView()
    let navigationBar = UINavigationBar()
    let weekKeysBar = UIStackView()
    let weekPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let bottomBar = UIView()
    let bottomBarBackground = BlurView()
    var weekVC : WeekVC
    var weekVCDisposeBag = DisposeBag()
    var entryEditingVC : EntryEditingVC {
        get {
            return pageVC.viewControllers?.first as! EntryEditingVC
        }
    }

    override init(_ viewModel: VM) {
        weekVC = WeekVC(viewModel.initialDate)
        super.init(viewModel)
        base.hasGuide = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "today".localized, style: .plain, target: nil, action: nil)
        view.backgroundColor = .white
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setUpTopBar()
        setUpPageVC()
        setUpBottomBar()
        view.bringSubview(toFront: topBar)
        bindWeekVC()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if base.firstAppearing {
            DispatchQueue.main.async {
                if let vc = self.pageVC.viewControllers?.first as? EntryEditingVC {
                    vc.becomeActive()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if base.guideView != nil {
            Local.defaults.shouldShowGuideCompletion = true
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(viewModel.cancel).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem?.rx.tap.asDriver().drive(onNext:{ [unowned self] () in
            let date = Date().trimmedTime
            switch date {
            case let date where date >= self.weekVC.firstDate && date <= self.weekVC.lastDate:
                self.weekVC.selectedDate.value = date
                break
            default:
                self.updateWeekVC(for:date)
                break
            }
            Answers.logCustomEvent(withName: "Today", customAttributes: nil)
        }).disposed(by: disposeBag)
    }

    func setUpBottomBar() {
        view.addSubview(bottomBar)
        bottomBar.easy.layout([
            Left(),
            Bottom().to(view, .bottomMargin),
            Right(),
            Height(50)
        ])

        bottomBarBackground.showTopSeparator = true
        bottomBar.addSubview(bottomBarBackground)
        bottomBarBackground.easy.layout([
            Top(),
            Left(),
            Right(),
            Bottom().to(view, .bottom)
        ])
    }

    @objc func keyboardWillChange(notification:NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboarFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let shown = keyboarFrame.origin.y < UIScreen.main.bounds.size.height

        UIView.animate(withDuration: 0.3) {
            self.bottomBar.easy.layout(Bottom(shown ? keyboarFrame.size.height : 0).to(self.view, shown ? .bottom : .bottomMargin))
            self.bottomBarBackground.easy.layout(Bottom(shown ? keyboarFrame.size.height : 0).to(self.view, .bottom))
            self.view.layoutIfNeeded()
        }
    }

    func setUpTopBar() {
        view.addSubview(topBar)
        topBar.easy.layout([
            Top().to(topLayoutGuide),
            Left(),
            Right(),
            Height(108)
        ])

        let topBarBackground = BlurView()
        topBar.addSubview(topBarBackground)
        topBarBackground.easy.layout([Top().to(view, .top), Left(), Right(), Bottom()])

        setUpNavigationBar()
        setUpWeekKeysBar()
        setUpWeekValuesBar()
    }

    func setUpNavigationBar() {
        topBar.addSubview(navigationBar)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.items = [navigationItem]
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)]
        navigationBar.easy.layout([
            Top(),
            Left(),
            Right(),
            Height(44)
        ])
    }

    func setUpWeekKeysBar() {
        topBar.addSubview(weekKeysBar)
        weekKeysBar.axis = .horizontal
        weekKeysBar.alignment = .center
        weekKeysBar.distribution = .fillEqually
        weekKeysBar.easy.layout([
            Top().to(navigationBar),
            Left(),
            Right(),
            Height(12)
        ])

        for symbol in Calendar.local.orderedWeekDaySymbols {
            let label = UILabel()
            label.font = .sdTextStyle5Font
            label.text = String(symbol.first!).uppercased()
            label.textAlignment = .center
            weekKeysBar.addArrangedSubview(label)
        }
    }

    func setUpWeekValuesBar() {
        weekPageVC.willMove(toParentViewController: self)
        addChildViewController(weekPageVC)
        topBar.addSubview(weekPageVC.view)
        weekPageVC.didMove(toParentViewController: self)

        weekPageVC.setViewControllers([weekVC], direction: .forward, animated: false, completion: nil)
        weekPageVC.dataSource = self
        weekPageVC.delegate = self
        weekPageVC.view.easy.layout([
            Top().to(weekKeysBar),
            Left(),
            Bottom(),
            Right()
        ])

        refreshWeekKeys()
    }

    func setUpPageVC() {
        pageVC.willMove(toParentViewController: self)
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.easy.layout(Edges())
        pageVC.didMove(toParentViewController: self)
        //TODO: become first responder
        pageVC.setViewControllers([EntryEditingVC(viewModel.viewModelForEntryEditing())]
            , direction:.forward, animated: false, completion: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
    }

    func refreshWeekKeys() {
        var date = weekVC.firstDate
        weekKeysBar.arrangedSubviews.forEach { (view) in
            let label = view as! UILabel
            let isSunday = date.weekDay == 1
            label.textColor = date <= Date() ? (isSunday ? .red : .black) : (isSunday ? .sdLightPeach : .sdSilver)
            date = date.tomorrow
        }
    }

    func weekVCDidSelect(date:Date) {
        let vc = pageVC.viewControllers?.first as! EntryEditingVC
        switch date {
        case let date where date < vc.viewModel.date:
            pageVC.setViewControllers([EntryEditingVC(viewModel.viewModelForEntryEditing(for:date))]
                , direction:.reverse, animated: true, completion: nil)
            break

        case let date where date > vc.viewModel.date:
            pageVC.setViewControllers([EntryEditingVC(viewModel.viewModelForEntryEditing(for:date))]
                , direction:.forward, animated: true, completion: nil)
            break
        default: break
        }
    }

    func updatedWeekVC(_ date: Date) -> WeekVC {
        weekVC = WeekVC(date)
        bindWeekVC()
        return weekVC
    }

    func updateWeekVC(for date: Date) {
        let selectedDate = weekVC.selectedDate.value
        weekPageVC.setViewControllers([updatedWeekVC(date)], direction: date < selectedDate ? .reverse : .forward, animated: true, completion: nil)
    }

    func bindWeekVC() {
        weekVCDisposeBag = DisposeBag()
        let driver = weekVC.selectedDate.asDriver()
        driver.drive(onNext:{ [weak self] (date) in
            self?.weekVCDidSelect(date: date)
            self?.refreshWeekKeys()
            self?.showNextGuide()
        }).disposed(by: weekVCDisposeBag)

        driver.map { (date) in return date.monthMedium }.drive(rx.title).disposed(by: weekVCDisposeBag)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        pageVC.viewControllers?.forEach({ (viewController) in
            viewController.setEditing(false, animated: true)
        })
    }

    func showNextGuide() {
        if let guide = base.guideView {
            UIView.transition(with: guide, duration: 0.25, options: .transitionCrossDissolve, animations: {
                guide.subviews.forEach({ (subview) in
                    if subview != guide.backgroundView {
                        subview.removeFromSuperview()
                    }
                })

                guide.highlight(self.viewModel.router.plusButton)

                let arrow = UIImageView(image:#imageLiteral(resourceName: "arrow-down"))
                guide.addSubview(arrow)
                arrow.easy.layout([Bottom(iPhoneX ? 84 : 50), CenterX(70)])

                let label = guide.createLabel("editingGuideSave")
                label.easy.layout([Left(42), Right(42), Bottom(13).to(arrow)])
            }, completion: nil)
        }
    }

    override func createGuide() {
        let guide = GuideView(frame: view.bounds)
        view.addSubview(guide)
        guide.highlight(weekVC.circle)

        let arrow = UIImageView(image:#imageLiteral(resourceName: "arrow-up"))
        guide.addSubview(arrow)
        arrow.easy.layout([Top(iPhoneX ? 167 : 133), Left(weekVC.circle.frame.maxX + 30).with(.medium), Right(<=10)])

        let dayLabel = guide.createLabel("editingGuideDay")
        dayLabel.easy.layout([Left(42), Right(42), Top(10).to(arrow)])

        let swipeLabel = guide.createLabel("editingGuideSwipes")
        swipeLabel.easy.layout([Left(42), Right(42), Top(16).to(dayLabel)])

        let swipeIcon = UIImageView(image: #imageLiteral(resourceName: "swipe-icon"))
        guide.addSubview(swipeIcon)
        swipeIcon.easy.layout([Top(14).to(swipeLabel), CenterX()])

        base.guideView = guide
    }

    //MARK: Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if pageViewController == pageVC {
            let viewController = viewController as! EntryEditingVC
            let vm = viewModel.viewModelForEntryEditing(before: viewController.viewModel)
            return vm.enabled ? EntryEditingVC(vm) : nil
        }
        else {
            let viewController = viewController as! WeekVC
            return WeekVC(Calendar.local.date(byAdding: .weekOfYear, value: -1, to: viewController.selectedDate.value)!)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if pageViewController == pageVC {
            let viewController = viewController as! EntryEditingVC
            let vm = viewModel.viewModelForEntryEditing(after: viewController.viewModel)
            return vm.enabled ? EntryEditingVC(vm) : nil
        }
        else {
            let viewController = viewController as! WeekVC

            if Date() < viewController.lastDate {
                //Selected week has current date. No possible to scroll next
                return nil
            }

            var targetDate = Calendar.local.date(byAdding: .weekOfYear, value: 1, to: viewController.selectedDate.value)!
            if targetDate > Date() {
                //Next week has current date and target date is future date, so reduce it to the current date
                targetDate = Date()
            }

            return WeekVC(targetDate)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if pageViewController == weekPageVC {
            if let pendingWeekVC = pendingViewControllers.first as? WeekVC {
                let addValue = pendingWeekVC.selectedDate.value > weekVC.selectedDate.value  ? 1 : -1
                let targetDate = Calendar.local.date(byAdding: .weekOfYear, value: addValue, to: weekVC.selectedDate.value)!
                if targetDate < Date() {
                    pendingWeekVC.selectedDate.value = targetDate
                }
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if pageViewController == pageVC {
            switch entryEditingVC.viewModel.date {
            case let date where date < weekVC.firstDate || date > weekVC.lastDate:
                updateWeekVC(for:date)
                break

            default:
                weekVC.selectedDate.value = entryEditingVC.viewModel.date
                break
            }

            Answers.logContentView(withName: "Editing", contentType: "Entry", contentId: entryEditingVC.viewModel.date.remoteDateString, customAttributes: nil)
        }
        else {
            weekVC = weekPageVC.viewControllers?.first as! WeekVC
            bindWeekVC()
        }
    }
}
