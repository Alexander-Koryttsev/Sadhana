//
//  SadhanaEntryCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy

class SadhanaEntryCell: UITableViewCell {
    let dateLabel = UILabel()
    let weekDayLabel = UILabel()
    let sadhanaEntryView = SadhanaEntryView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: NSStringFromClass(SadhanaEntryCell.self))

        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        separatorInset = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: 0)

        contentView.addSubview(sadhanaEntryView)
        sadhanaEntryView <- [
            CenterY(),
            Left(60).to(contentView),
            Right().to(contentView, .rightMargin)
        ]

        contentView.addSubview(dateLabel)
        dateLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
        dateLabel <- [
            CenterY(),
            Right(32).to(sadhanaEntryView)
        ]

        contentView.addSubview(weekDayLabel)
        weekDayLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightBold)
        weekDayLabel.textColor = UIColor.sdSilver
        weekDayLabel <- [
            Left(5).to(dateLabel),
            Bottom(2).to(dateLabel, .bottom)
        ]


    }

    func map(_ entry: SadhanaEntry, maxRoundsCount:Int16) {
        dateLabel.text = entry.date.day.description
        weekDayLabel.text = entry.date.weekDayShort

        sadhanaEntryView.map(entry, maxRoundsCount: maxRoundsCount)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
