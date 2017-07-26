//
//  SadhanaEntryView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy

class SadhanaEntryView : UIView {
    let japaView = JapaView()
    let japaCountLabel = UILabel()
    let readingImageView = OnOffImageView(offImage: #imageLiteral(resourceName: "book-icon-empty"), onImage: #imageLiteral(resourceName: "book-icon-filled"))
    let readingLabel = UILabel()
    let kirtanImageView = OnOffImageView(offImage: #imageLiteral(resourceName: "kirtan-icon-empty"), onImage: #imageLiteral(resourceName: "kirtan-icon-filled"))

    init() {
        super.init(frame:CGRect())
        self.addSubview(kirtanImageView)
        kirtanImageView <- [
            CenterY(),
            Right()
        ]

        self.addSubview(readingImageView)
        readingImageView <- [
            CenterY(),
            Right(32).to(kirtanImageView),
        ]

        self.addSubview(readingLabel)
        readingLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightRegular)
        readingLabel <- [
            CenterY(),
            Left(4).to(readingImageView)
        ]

        self.addSubview(japaView)
        japaView <- [
            Top(),
            Left(),
            Height(22),
            Bottom(),
            Right(32).to(readingImageView)
        ]

        self.addSubview(japaCountLabel)
        japaCountLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightRegular)
        japaCountLabel <- [
            CenterY(),
            Left(5).to(japaView)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func map(_ entry: SadhanaEntry, maxRoundsCount:Int16) {
        japaCountLabel.text = (entry.japaCount7_30 + entry.japaCount10 + entry.japaCount18 + entry.japaCount24).description

        readingImageView.isOn = entry.reading.rawValue > 0
        readingLabel.text = entry.reading.rawValue.description
        kirtanImageView.isOn = entry.kirtan

        japaView.map(entry, maxCount: maxRoundsCount)
    }
}
