//
//  EntryCell.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/17/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import EasyPeasy

class EntryCell: UITableViewCell {
    let dateLabel = UILabel()
    let weekDayLabel = UILabel()
    let entryView = EntryView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: NSStringFromClass(EntryCell.self))

        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        separatorInset = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: 0)
        backgroundColor = .white
        contentView.backgroundColor = .white

        contentView.addSubview(entryView)
        entryView.easy.layout([
            CenterY(),
            Left(60).to(contentView),
            Right().to(contentView, .rightMargin)
        ])

        contentView.addSubview(dateLabel)
        dateLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        dateLabel.easy.layout([
            CenterY(),
            Right(32).to(entryView)
        ])

        contentView.addSubview(weekDayLabel)
        weekDayLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.bold)
        weekDayLabel.textColor = UIColor.sdSilver
        weekDayLabel.easy.layout([
            Left(5).to(dateLabel),
            Bottom(2).to(dateLabel, .bottom)
        ])
    }

    func map(_ entry: Entry, maxRoundsCount:Int16) {
        set(date: entry.date)
        entryView.map(entry, maxRoundsCount: maxRoundsCount)
    }

    func clear(_ date: Date) {
        set(date: date)
        entryView.clear()
    }

    func set(date:Date) {
        let isSunday = date.weekDay == 1

        dateLabel.text = date.day.description
        dateLabel.textColor = isSunday ? .red : .black

        weekDayLabel.text = date.weekDayShort.uppercased()
        weekDayLabel.textColor = isSunday ? .sdLightPeach : .sdSilver
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
