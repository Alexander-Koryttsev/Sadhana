//
//  WeekDaysVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/25/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import UIKit
import EasyPeasy
import RxCocoa
import RxSwift

class WeekVC: UIViewController {

    private let stackView = UIStackView()
    let circle = CircleView()

    let disposeBag = DisposeBag()
    var labels : [UILabel] {
        get {
            return stackView.arrangedSubviews as! [UILabel]
        }
    }
    let selectedDate : Variable<Date>

    let firstDate : Date
    let lastDate : Date

    init(_ selectedDate: Date) {
        let trimmedSelectedDate = selectedDate.trimmedTime
        self.selectedDate = Variable(trimmedSelectedDate)
        firstDate = Calendar.local.date(byAdding: .day, value: -trimmedSelectedDate.weekDayIndex, to: trimmedSelectedDate)!
        lastDate = Calendar.local.date(byAdding: .day, value: 6 - trimmedSelectedDate.weekDayIndex, to: trimmedSelectedDate)!

        super.init(nibName: nil, bundle: nil)

        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.easy.layout(Edges())

        let currentDate = Date().trimmedTime

        for i in (0..<7) {
            let date = Calendar.local.date(byAdding: .day, value: i, to: firstDate)!
            let label = UILabel()
            label.text = date.day.description
            label.highlightedTextColor = .white
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            stackView.addArrangedSubview(label)
            let isSunday = date.weekDay == 1
            //label.textColor = date <= Date() ? (isSunday ? .red : .black) : (isSunday ? .sdLightPeach : .sdSilver)

            if date <= currentDate {
                let gesture = UITapGestureRecognizer()
                gesture.rx.event.map({ gesture in return date }).bind(to: self.selectedDate).disposed(by: disposeBag)
                label.addGestureRecognizer(gesture)

                if date == currentDate {
                    label.textColor = .sdTangerine
                }
                else {
                    label.textColor = isSunday ? .red : .black
                }
            }
            else {
                label.textColor = isSunday ? .sdLightPeach : .sdSilver
            }

            if i == trimmedSelectedDate.weekDayIndex {
                label.isHighlighted = true
            }
        }

        stackView.insertSubview(circle, at: 0)
        circle.easy.layout([
            Size(35),
            CenterY(),
            CenterX()
        ])

        self.selectedDate.asDriver().drive(onNext: { [unowned self] (date) in
            self.labels.forEach { (label) in
                label.isHighlighted = false
            }

            self.labels[self.selectedDate.value.weekDayIndex].isHighlighted = true

            self.circle.tintColor = date == Date().trimmedTime ? .sdTangerine : .black
            self.circle.setNeedsDisplay()
            self.circle.easy.layout(CenterX().to(self.stackView.arrangedSubviews[self.selectedDate.value.weekDayIndex]))
            self.stackView.layoutIfNeeded()
        }).disposed(by: disposeBag)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

