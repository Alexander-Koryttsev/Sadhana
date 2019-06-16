//
//  WeekDaysVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 7/25/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//


import EasyPeasy


class WeekVC: UIViewController {

    private let stackView = UIStackView()
    let circle = CircleView()

    let disposeBag = DisposeBag()
    var labels : [UILabel] {
        get {
            return stackView.arrangedSubviews as! [UILabel]
        }
    }
    let selectedDate : RxSwift.Variable<LocalDate>

    let firstDate : LocalDate
    let lastDate : LocalDate

    init(_ selectedDate: LocalDate) {
        self.selectedDate = RxSwift.Variable(selectedDate)
        firstDate = selectedDate.add(days: -selectedDate.weekDayIndex)
        lastDate = selectedDate.add(days: 6 - selectedDate.weekDayIndex)

        super.init(nibName: nil, bundle: nil)

        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.easy.layout(Edges())

        let currentDate = LocalDate()

        for i in (0..<7) {
            let date = firstDate.add(days: i)
            let label = UILabel()
            label.text = date.day.description
            label.highlightedTextColor = .white
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            stackView.addArrangedSubview(label)
            let isSunday = date.weekDay == 1

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
            if i == selectedDate.weekDayIndex {
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

            self.circle.tintColor = date.isToday ? .sdTangerine : .black
            self.circle.setNeedsDisplay()
            self.circle.easy.layout(CenterX().to(self.stackView.arrangedSubviews[self.selectedDate.value.weekDayIndex]))
            self.stackView.layoutIfNeeded()
        }).disposed(by: disposeBag)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

