//
//  OtherGraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/22/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import RxCocoa
import AlamofireImage
import EasyPeasy

import Crashlytics

class OtherGraphVC : GraphVC<OtherGraphVM> {

    var headerVisible = true {
        didSet {
            if oldValue != headerVisible {
                UIView.transition(with: navigationController!.navigationBar, duration: 0.15, options: .transitionCrossDissolve, animations:{ self.title = nil }, completion: { _ in
                    UIView.transition(with: self.navigationController!.navigationBar, duration: 0.15, options: .transitionCrossDissolve, animations:self.updateTitle, completion: nil)
                })
            }
        }
    }

    var userNameHeight = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

        if let url = viewModel.info.avatarURL {
            let avatarSize = ScreenWidth
            let avatarView = UIImageView(frame:CGRect(x:0, y:0, width: avatarSize, height: avatarSize))
            avatarView.af_setImage(withURL:url, placeholderImage:Common.avatarPlaceholder, imageTransition:.crossDissolve(0.25))

            let gradient = LinearGradientView()
            avatarView.addSubview(gradient)
            gradient.easy.layout([Left(), Bottom(), Right(), Height(108)])

            let userNameLabel = UILabel()
            userNameLabel.text = viewModel.info.userName
            userNameLabel.textColor = .white
            userNameLabel.textAlignment = .center
            userNameLabel.font = UIFont.systemFont(ofSize: 22)
            userNameLabel.sizeToFit()
            userNameHeight = 22 + userNameLabel.bounds.size.height + 22
            avatarView.addSubview(userNameLabel)
            userNameLabel.easy.layout([Left(10), Bottom(22), Right(10)])

            UIView.performWithoutAnimation {
                self.tableView.tableHeaderView = avatarView
                avatarView.setNeedsLayout()
                avatarView.layoutIfNeeded()
            }
        }
        updateTitle()
        viewModel.refresh.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "Other Graph", contentType: nil, contentId: nil, customAttributes: ["UserID" : viewModel.info.userID])

        NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground).map { _ in return }.bind(to: viewModel.refresh).disposed(by: viewModel.disappearBag)
    }

    override func bindViewModel() {
        super.bindViewModel()

        setUpDefaultActivityIndicator(with: viewModel.pageRunning.asDriver().map { running, _ -> Bool in
            return running
        })

        viewModel.firstPageRunning.drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)

        viewModel.dataDidReload.asDriver(onErrorJustReturn: ()).drive(onNext: { [unowned self] () in
            self.reloadData()
        }).disposed(by: disposeBag)

        viewModel.pageDidUpdate.asDriver(onErrorJustReturn: 0).drive(onNext: { [unowned self] (section) in
            if let paths = self.tableView.indexPathsForVisibleRows {
                for path in paths {
                    if path.section == section {
                        if let cell = self.tableView.cellForRow(at: path) {
                            self.setUp(cell, at: path)
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)
    }

    func updateTitle() {
        title = headerVisible ? "profile".localized : viewModel.info.userName
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerVisible = (tableView.contentOffset.y + TopInset)  < ScreenWidth
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let difference = ScreenWidth - (targetContentOffset.pointee.y + TopInset)
        if difference > 0 && difference < userNameHeight {
            if difference < userNameHeight/2.0 || velocity.y > 0 { //Bottom
                targetContentOffset.initialize(to: CGPoint(x:0, y:ScreenWidth - TopInset))
            }
            else { //Top
                targetContentOffset.initialize(to: CGPoint(x:0, y:ScreenWidth - TopInset - userNameHeight))
            }
        }
    }
}
