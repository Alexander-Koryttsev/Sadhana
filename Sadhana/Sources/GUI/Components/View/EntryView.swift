//
//  EntryView.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import EasyPeasy



class EntryView : UIView {
    let japaView = JapaView()
    let japaCountLabel = UILabel()
    let readingImageView = OnOffImageView(offImage: #imageLiteral(resourceName: "book-icon-empty"), onImage: #imageLiteral(resourceName: "book-icon-filled"))
    let readingLabel = UILabel()
    let kirtanImageView = OnOffImageView(offImage: #imageLiteral(resourceName: "kirtan-icon-empty"), onImage: #imageLiteral(resourceName: "kirtan-icon-filled"))

    init() {
        super.init(frame:CGRect())
        addSubview(kirtanImageView)
        kirtanImageView.easy.layout([
            CenterY(),
            Right(),
            Top(>=0),
            Bottom(>=0)
        ])

        addSubview(readingImageView)
        readingImageView.easy.layout([
            CenterY(),
            Right(38).to(kirtanImageView),
        ])

        addSubview(readingLabel)
        readingLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        readingLabel.easy.layout([
            CenterY(),
            Left(4).to(readingImageView)
        ])

        addSubview(japaView)
        japaView.easy.layout([
            CenterY(),
            Left(),
            Right(32).to(readingImageView)
        ])

        self.addSubview(japaCountLabel)
        japaCountLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        japaCountLabel.easy.layout([
            CenterY(),
            Left(5).to(japaView)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clear() {
        japaView.clear()
        japaCountLabel.text = "0"
        readingImageView.isOn = false
        readingLabel.text = "0"
        kirtanImageView.isOn = false
        updateLabelColors()
    }
    
    

    func map(_ entry: Entry, maxRoundsCount:Int16) {
        japaCountLabel.text = (entry.japaCount7_30 + entry.japaCount10 + entry.japaCount18 + entry.japaCount24).description

        readingImageView.isOn = entry.reading.rawValue > 0
        readingLabel.text = Local.defaults.readingOnlyInMinutes ? entry.reading.rawValue.description : entry.reading.shortString
        kirtanImageView.isOn = entry.kirtan

        japaView.map(entry, maxCount: maxRoundsCount)
        updateLabelColors()
    }

    private func updateLabelColors() {
        japaCountLabel.textColor = japaCountLabel.text == "0" ? .sdSilver : .black
        readingLabel.textColor = readingLabel.text == "0" ? .sdSilver : .black
    }
}
