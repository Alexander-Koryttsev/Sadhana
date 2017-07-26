//
//  EditingVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import EasyPeasy

class EditingVC: BaseVC<EditingVM>, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let topBar = UIView()
    let navigationBar = UINavigationBar()
    let weekKeysBar = UIStackView()
    let weekPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var weekVC = WeekVC(Date())
    var entryEditingVC : EntryEditingVC { get {
        return pageVC.viewControllers?.first as! EntryEditingVC
    }}

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        view.backgroundColor = .white
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setUpTopBar()
        setUpPageVC()
        view.bringSubview(toFront: topBar)
        bindWeekVC()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func bindViewModel() {
        navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(viewModel.cancel).disposed(by: disposeBag)
    }

    func setUpTopBar() {
        view.addSubview(topBar)
        topBar <- [
            Top(),
            Left(),
            Right(),
            Height(128)
        ]

        let topBarBackground = UINavigationBar()
        topBar.addSubview(topBarBackground)
        topBarBackground <- Edges()

        setUpNavigationBar()
        setUpWeekKeysBar()
        setUpWeekValuesBar()
    }

    func setUpNavigationBar() {
        topBar.addSubview(navigationBar)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.items = [navigationItem]
        navigationBar <- [
            Top(20),
            Left(),
            Right(),
            Height(44)
        ]
    }

    func setUpWeekKeysBar() {
        topBar.addSubview(weekKeysBar)
        weekKeysBar.axis = .horizontal
        weekKeysBar.alignment = .center
        weekKeysBar.distribution = .fillEqually
        weekKeysBar <- [
            Top().to(navigationBar),
            Left(),
            Right(),
            Height(12)
        ]

        for symbol in DateFormatter().veryShortWeekdaySymbols {
            let label = UILabel()
            label.font = .sdTextStyle5Font
            label.text = String(symbol.characters.first!).uppercased()
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
        weekPageVC.view <- [
            Top().to(weekKeysBar),
            Left(),
            Bottom(),
            Right()
        ]

        refreshWeekKeys()
    }

    func setUpPageVC() {
        pageVC.willMove(toParentViewController: self)
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view <- Edges()
        pageVC.didMove(toParentViewController: self)
        //TODO: become first responder
        pageVC.setViewControllers([EntryEditingVC(viewModel.viewModelForEntryEditing()!)]
            , direction:.forward, animated: false, completion: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
    }

    func refreshWeekKeys() {
        var date = weekVC.firstDate
        weekKeysBar.arrangedSubviews.forEach { (view) in
            let label = view as! UILabel
            label.textColor = date <= Date() ? .black : .sdSilver
            date = date.tomorrow
        }
    }

    func updateWeekVC(_ date: Date) -> WeekVC {
        weekVC = WeekVC(date)
        bindWeekVC()
        return weekVC
    }

    func bindWeekVC() {
        let driver = weekVC.selectedDate.asDriver()
        driver.drive(onNext:{ [weak self] (date) in
            self?.weekVCDidSelect(date: date)
            self?.refreshWeekKeys()
        })  .disposed(by: weekVC.disposeBag)

        driver.map { (date) in return date.monthMedium }.drive(rx.title).disposed(by: weekVC.disposeBag)
    }

    func weekVCDidSelect(date:Date) {
        let vc = pageVC.viewControllers?.first as! EntryEditingVC
        switch date {
        case let date where date < vc.viewModel.date:
            pageVC.setViewControllers([EntryEditingVC(viewModel.viewModelForEntryEditing(date)!)]
                , direction:.reverse, animated: true, completion: nil)
            break

        case let date where date > vc.viewModel.date:
            pageVC.setViewControllers([EntryEditingVC(viewModel.viewModelForEntryEditing(date)!)]
                , direction:.forward, animated: true, completion: nil)
            break
        default: break
        }
    }

    //MARK: Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if pageViewController == pageVC {
            let viewController = viewController as! EntryEditingVC
            if let vm = viewModel.viewModelForEntryEditing(before: viewController.viewModel) {
                return EntryEditingVC(vm)
            }
        }
        else {
            let viewController = viewController as! WeekVC
            var components = Calendar.current.dateComponents(in: TimeZone.current, from: viewController.selectedDate.value)
            components.day = components.day! - 7
            return WeekVC(components.date!)
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if pageViewController == pageVC {
            let viewController = viewController as! EntryEditingVC
            if let vm = viewModel.viewModelForEntryEditing(after: viewController.viewModel) {
                return EntryEditingVC(vm)
            }
        }
        else {
            let viewController = viewController as! WeekVC
            var components = Calendar.current.dateComponents(in: TimeZone.current, from: viewController.selectedDate.value)
            components.day = components.day! + 7
            let date = components.date!
            return date.trimmedTime <= Date().trimmedTime ? WeekVC(date) : nil
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if pageViewController == pageVC {
            switch entryEditingVC.viewModel.date {
            case let date where date < weekVC.firstDate:
                weekPageVC.setViewControllers([updateWeekVC(date)], direction: .reverse, animated: true, completion: nil)
                break

            case let date where date > weekVC.lastDate:
                weekPageVC.setViewControllers([updateWeekVC(date)], direction: .forward, animated: true, completion: nil)
                break
            default:
                weekVC.selectedDate.value = entryEditingVC.viewModel.date
                break
            }
        }
        else {
            weekVC = weekPageVC.viewControllers?.first as! WeekVC
            bindWeekVC()
        }
    }
}
