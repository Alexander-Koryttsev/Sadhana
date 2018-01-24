//: Playground - noun: a place where people can play

import UIKit
import Foundation

import PlaygroundSupport

let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
containerView.backgroundColor = UIColor.white


let contentView = UIView(frame:CGRect(x:0, y:0, width:100, height:50))

let top = UIView(frame:CGRect(x:0, y:0, width:100, height:25))
top.backgroundColor = .blue
contentView.addSubview(top)

let bottom = UIView(frame:CGRect(x:0, y:25, width:100, height:25))
bottom.backgroundColor = .yellow
contentView.addSubview(bottom)

containerView.addSubview(contentView)


var animation = CAKeyframeAnimation(keyPath: "position.y")

var path = CGMutablePath()
path.move(to: CGPoint(x:0, y:0))
path.move(to: CGPoint(x:0, y:400))
path.move(to: CGPoint(x:0, y:0))

//animation.path = path
//animation.path = CGPath(rect: CGRect(x:0, y:0, width:0, height:400), transform: nil)
animation.values = [ 0, 400, 0 ]
animation.duration = 2
animation.repeatCount = MAXFLOAT
animation.rotationMode = kCAAnimationRotateAuto

contentView.layer.add(animation, forKey: "animation")

PlaygroundPage.current.liveView = containerView
