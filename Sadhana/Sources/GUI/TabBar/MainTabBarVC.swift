//
//  MainTabBarVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit

import RxCocoa
import EasyPeasy

class MainTabBarVC : BaseTabBarVC<MainTabBarVM> {
    let editingButton = UIFactory.editingButton
    var guideBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEditingButton()
        base.hasGuide = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Local.defaults.shouldShowGuideCompletion {
            Local.defaults.shouldShowGuideCompletion = false

            let completionBackground = UIView(frame:view.bounds)
            completionBackground.backgroundColor = UIColor.init(white: 0, alpha: 0.7)

            let sheetHeight = CGFloat(284)
            let sheet = UIView(frame:CGRect(x:view.bounds.size.width/2.0 - 150, y:view.bounds.size.height/2.0 - sheetHeight/2.0, width:300, height:sheetHeight))
            sheet.layer.masksToBounds = true
            sheet.layer.cornerRadius = 7
            sheet.backgroundColor = .white
            completionBackground.addSubview(sheet)

            let successIcon = UIImageView(image:#imageLiteral(resourceName: "success-icon"))
            successIcon.center = CGPoint(x:sheet.bounds.size.width/2.0, y:sheetHeight/2.0 - 30)
            sheet.addSubview(successIcon)

            let label = UILabel()
            label.text = "editingGuideEnjoy".localized
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18)
            label.sizeToFit()
            label.center = CGPoint(x:sheet.bounds.size.width/2.0, y:successIcon.center.y + 70)
            sheet.addSubview(label)

            let button = Button()
            button.setTitle("begin".localized, for: .normal)
            button.frame = CGRect(x:0, y:sheetHeight - 50, width:sheet.bounds.size.width, height:50)
            sheet.addSubview(button)

            button.rx.tap.asDriver().drive(onNext: { [unowned self] () in
                UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    completionBackground.removeFromSuperview()
                }, completion: nil)
            }).disposed(by: guideBag)

            self.view.addSubview(completionBackground)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let items = tabBar.items, items.count == 2, iPhone {
            let offset = CGFloat(16)
            let leftItem = tabBar.items?.first!
            leftItem?.titlePositionAdjustment = UIOffset(horizontal: -1 * offset, vertical: 0)
            let rightItem = tabBar.items?.last!
            rightItem?.titlePositionAdjustment = UIOffset(horizontal: offset, vertical: 0)
        }

        tabBar.bringSubview(toFront: editingButton)
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        tabBar.isHidden = (viewControllers?.count ?? 0) < 2
    }

    private func setUpEditingButton() {
        tabBar.addSubview(editingButton)
        editingButton.easy.layout([
            CenterX(),
            Size(editingButton.bounds.size),
            BottomMargin(5)
        ])
        editingButton.addTarget(viewModel, action:#selector(MainTabBarVM.addEntry), for: .touchUpInside)
    }

    override func createGuide() {
        let guide = GuideView(frame: view.bounds)
        view.addSubview(guide)

        let alert = guide.createAlert()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Illustration"))
        alert.contentView.addSubview(imageView)
        imageView.easy.layout(Edges())

        let messageBackground = UIView()
        messageBackground.backgroundColor = UIColor(white: 1, alpha: 0.8)
        alert.contentView.addSubview(messageBackground)
        messageBackground.easy.layout([Left(), Bottom(), Right(), Height(128)])

        let messageTitle = UILabel()
        messageTitle.text = "guide_app_updated_title".localized
        messageTitle.textAlignment = .center
        messageTitle.numberOfLines = 2
        messageTitle.font = .boldSystemFont(ofSize:18)
        messageBackground.addSubview(messageTitle)
        messageTitle.easy.layout([Top(18), Left(25), Right(25)])

        let messageBody = UILabel()
        messageBody.text = "guide_app_updated_message".localized
        messageBody.textAlignment = .center
        messageBody.textColor = .sdBrownishGrey
        messageBody.numberOfLines = 2
        messageBody.font = .systemFont(ofSize:13)
        messageBackground.addSubview(messageBody)
        messageBody.easy.layout([Top(12).to(messageTitle, .bottom), Left(25), Right(25)])

        alert.button.setTitle("guide_app_udpated_button".localized, for: .normal)
        alert.button.rx.tap.subscribe(onNext: { [unowned self] () in
            self.showFeaturesGuide()
        }).disposed(by: guideBag)

        base.guideView = guide
        playSound("tada")
    }

    func showFeaturesGuide() {
        guideBag = DisposeBag()
        if let guide = base.guideView,
            let alert = guide.alert {

            alert.contentView.removeAllSubviews()
            let title = UILabel()
            title.text = "guide_features_title".localized
            title.font = .boldSystemFont(ofSize: 30)
            alert.contentView.addSubview(title)
            title.easy.layout([Top(58), CenterX()])

            let noInetIcon = UIImageView(image: #imageLiteral(resourceName: "no-internet-icon"))
            alert.contentView.addSubview(noInetIcon)
            noInetIcon.easy.layout([Top(29).to(title), Left().to(title, .left)])

            let noInetTitle = UILabel()
            noInetTitle.text = "guide_feature_offline".localized
            noInetTitle.textColor = .sdBrownishGrey
            noInetTitle.textAlignment = .center
            noInetTitle.font = .systemFont(ofSize: 13)
            noInetTitle.numberOfLines = 2
            alert.contentView.addSubview(noInetTitle)
            noInetTitle.easy.layout([Top(16).to(noInetIcon), CenterX().to(noInetIcon), Bottom(62).to(alert.button, .top)])


            let fastIcon = UIImageView(image: #imageLiteral(resourceName: "faster-icon"))
            alert.contentView.addSubview(fastIcon)
            fastIcon.easy.layout([CenterY(4).to(noInetIcon), Right().to(title, .right)])

            let fastTitle = UILabel()
            fastTitle.text = "guide_feature_fast_fill".localized
            fastTitle.textColor = .sdBrownishGrey
            fastTitle.textAlignment = .center
            fastTitle.font = .systemFont(ofSize: 13)
            fastTitle.numberOfLines = 2
            alert.contentView.addSubview(fastTitle)
            fastTitle.easy.layout([CenterY().to(noInetTitle), CenterX().to(fastIcon)])

            alert.button.setTitle("guide_features_button".localized, for: .normal)

            alert.button.rx.tap.subscribe(onNext: { [unowned self] () in
                UIView.transition(with: guide, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    guide.removeAlert()
                    self.showPlusButtonGuide()
                }, completion: nil)
            }).disposed(by: guideBag)

            alert.contentView.layoutIfNeeded()

            UIView.transition(with: alert.contentView, duration: 0.25, options: .transitionCrossDissolve, animations: nil, completion: nil)

            UIView.animate(withDuration: 0.25, animations: {
                guide.layoutIfNeeded()
            })
        }
    }

    func showPlusButtonGuide() {
        if let guide = base.guideView {
            guide.highlight(editingButton)

            let arrow = UIImageView(image:#imageLiteral(resourceName: "arrow-down"))
            guide.addSubview(arrow)
            arrow.easy.layout([Bottom(iPhoneX ? 84 : 50), CenterX(80)])

            let label = guide.createLabel("myGraphGuidePlusButton")
            label.easy.layout([Left(42), Right(42), Bottom(10).to(arrow)])
        }
    }
}
