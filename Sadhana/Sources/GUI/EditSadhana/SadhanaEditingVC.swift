//
//  SadhanaEditingVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/19/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import EasyPeasy

class SadhanaEditingVC: BaseVC<SadhanaEditingVM>, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let topBar = UIView()
    let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        title = "Edit"
        view.backgroundColor = .white
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setUpTopBar()
        setUpPageVC()
        view.bringSubview(toFront: topBar)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }

    override func bindViewModel() {
        navigationItem.leftBarButtonItem?.rx.tap.asDriver().drive(viewModel.cancel).disposed(by: disposeBag)
    }

    func setUpTopBar() {
        view.addSubview(topBar)
        topBar <- [
            Top().to(topLayoutGuide),
            Left(),
            Right(),
            Height(30)
        ]

        let navBar = UINavigationBar()
        topBar.addSubview(navBar)
        navBar <- Edges()
    }

    func setUpPageVC() {
        pageVC.willMove(toParentViewController: self)
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view <- [
            Top().to(view),
            Left(),
            Bottom(),
            Right()
        ]
        pageVC.didMove(toParentViewController: self)
        pageVC.setViewControllers([SadhanaEntryEditingVC(viewModel.viewModelForEntryEditing()!)]
            , direction:.forward, animated: false, completion: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
    }

    //MARK: Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
       let viewController = viewController as! SadhanaEntryEditingVC
        if let vm = viewModel.viewModelForEntryEditing(before: viewController.viewModel) {
            return SadhanaEntryEditingVC(vm)
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! SadhanaEntryEditingVC
        if let vm = viewModel.viewModelForEntryEditing(after: viewController.viewModel) {
            return SadhanaEntryEditingVC(vm)
        }

        return nil
    }
    
    //MARK: Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
