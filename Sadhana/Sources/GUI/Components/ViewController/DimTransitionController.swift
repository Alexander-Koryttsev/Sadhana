//
//  TransitionController.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/3/19.
//  Copyright © 2019 Alexander Koryttsev. All rights reserved.
//

import Foundation


class DimTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DimPresentingAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DimDismissingAnimator()
    }
}

let DimTransitionDuration = 0.3

class DimPresentingAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DimTransitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = toVC.view!
        let containerView = transitionContext.containerView

        var frame = containerView.bounds
        frame.origin.x = 0
        frame.origin.y = frame.size.height;
        toView.frame = frame

        containerView.addSubview(toView)
        containerView.backgroundColor = UIColor.init(white: 0, alpha: 0.0)

        UIView.animate(withDuration: DimTransitionDuration, delay: 0, options: .curveEaseOut, animations: {
            frame.origin.x = 0
            frame.origin.y = 0
            toView.frame = frame
            containerView.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}

class DimDismissingAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DimTransitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let fromView = fromVC.view!
        let containerView = transitionContext.containerView

        var frame = fromView.frame
        frame.origin.y = containerView.bounds.size.height;

        UIView.animate(withDuration: DimTransitionDuration, delay: 0, options: .curveEaseIn, animations: {
            fromView.frame = frame
            containerView.backgroundColor = .clear
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}


