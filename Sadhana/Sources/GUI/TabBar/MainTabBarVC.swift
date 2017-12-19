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
    override var hasGuide: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEditingButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let items = tabBar.items, items.count == 2 {
            let offset = CGFloat(16)
            let leftItem = tabBar.items?.first!
            leftItem?.titlePositionAdjustment = UIOffset(horizontal: -1 * offset, vertical: 0)
            let rightItem = tabBar.items?.last!
            rightItem?.titlePositionAdjustment = UIOffset(horizontal: offset, vertical: 0)
        }

        tabBar.bringSubview(toFront: editingButton)

        if Local.defaults.shouldShowGuideCompletion {
            Local.defaults.shouldShowGuideCompletion = false

            let completionBackground = UIView(frame:view.bounds)
            completionBackground.backgroundColor = UIColor.init(white: 0, alpha: 0.7)

            let sheetHeight = CGFloat(284)
            let sheet = UIView(frame:CGRect(x:10, y:view.bounds.size.height/2.0 - sheetHeight/2.0, width:view.bounds.size.width - 20, height:sheetHeight))
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
            }).disposed(by: disposeBag)

            UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.view.addSubview(completionBackground)
            }, completion: nil)
        }
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
        guide.highlight(editingButton)

        let arrow = UIImageView(image:#imageLiteral(resourceName: "arrow-down"))
        guide.addSubview(arrow)
        arrow.easy.layout([Bottom(iPhoneX ? 84 : 50), CenterX(80)])

        let label = guide.createLabel("myGraphGuidePlusButton")
        label.easy.layout([Left(42), Right(42), Bottom(10).to(arrow)])

        guideView = guide
    }
}
