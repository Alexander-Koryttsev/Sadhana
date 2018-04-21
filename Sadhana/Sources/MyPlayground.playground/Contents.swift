//: Playground - noun: a place where people can play
import UIKit
import Foundation

import PlaygroundSupport


let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
containerView.backgroundColor = UIColor.white

let label = UILabel(frame: CGRect(x: 10, y: 0, width: 300, height: 100))



let attributedString = NSMutableAttributedString(string: "Хей John, Вы получили      0.56  чаммикоинов за оплату", attributes: [
    .font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
    .foregroundColor: UIColor(white: 1.0, alpha: 1.0)
    ])
attributedString.addAttribute(.foregroundColor, value: UIColor(red: 1.0, green: 204.0 / 255.0, blue: 0.0, alpha: 1.0), range: NSRange(location: 27, length: 4))

containerView.backgroundColor = .black
label.numberOfLines = 0
label.textColor = .white
label.attributedText = attributedString

containerView.addSubview(label)





PlaygroundPage.current.liveView = containerView


