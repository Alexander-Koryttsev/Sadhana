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
    let topBar = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        title = "Edit"
        setUpTopBar()
        setUpPageView()
        view.backgroundColor = .white
        super.viewDidLoad()
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
            Height(30)
        ]
    }

    func setUpPageView() {
        pageVC.willMove(toParentViewController: self)
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view <- [
            Top().to(topBar),
            Left(),
            Bottom(),
            Right()
        ]
        pageVC.didMove(toParentViewController: self)
    }

    //MARK: Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
