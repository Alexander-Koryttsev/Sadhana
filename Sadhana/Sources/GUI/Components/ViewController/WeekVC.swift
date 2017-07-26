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
    private let circle = CircleView()

    let disposeBag = DisposeBag()
    var labels : [UILabel] { get {
        return stackView.arrangedSubviews as! [UILabel]
    }}
    let selectedDate : Variable<Date>

    var selectedWeekDay : Int { get {
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: selectedDate.value)
        return components.weekday!
    } set {
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: selectedDate.value)
        components.day = components.day! - components.weekday! + newValue
        selectedDate.value = components.date!
    }}

    var firstDate : Date { get {
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: selectedDate.value)
        components.day = components.day! - components.weekday! + 1
        return components.date!
    }}

    var lastDate : Date { get {
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: selectedDate.value)
        components.day = components.day! - components.weekday! + 7
        return components.date!
    }}

    init(_ selectedDate: Date) {
        self.selectedDate = Variable(selectedDate.trimmedTime)

        super.init(nibName: nil, bundle: nil)

        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView <- Edges()

        var components = Calendar.current.dateComponents(in: TimeZone.current, from: self.selectedDate.value)
        let currentDate = Date().trimmedTime
        let selectedWeekDay = components.weekday!
        components.day = components.day! - components.weekday! + 1

        for i in (1...7) {
            let label = UILabel()
            label.text = components.day!.description
            label.highlightedTextColor = .white
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            stackView.addArrangedSubview(label)
            let date = components.date!

            if date <= currentDate {
                let gesture = UITapGestureRecognizer()
                gesture.rx.event.map({ _ in return date }).bind(to: self.selectedDate).disposed(by: disposeBag)
                label.addGestureRecognizer(gesture)

                if date == currentDate {
                    label.textColor = .sdTangerine
                }
            }
            else {
                label.textColor = .sdSilver
            }

            if i == selectedWeekDay {
                label.isHighlighted = true
            }

            components.day = components.day! + 1
        }

        stackView.insertSubview(circle, at: 0)
        circle <- [
            Size(35),
            CenterY(),
            CenterX().to(stackView.arrangedSubviews[selectedWeekDay - 1])
        ]

        self.selectedDate.asDriver().drive(onNext: { [unowned self] (date) in
            self.labels.forEach { (label) in
                label.isHighlighted = false
            }

            self.labels[self.selectedWeekDay - 1].isHighlighted = true

            self.circle.tintColor = date == Date().trimmedTime ? .sdTangerine : .black
            self.circle.setNeedsDisplay()
            self.circle <- CenterX().to(self.stackView.arrangedSubviews[self.selectedWeekDay - 1])
            self.stackView.layoutIfNeeded()
        }).disposed(by: disposeBag)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

