//
//  TransitioningDelegate.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//
//
//  I pulled this in from one of my personal projects. This is just added polish for endgame
//
//

import Foundation
import UIKit
final class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return PresentationController(presentedViewController: presented, presenting: presenting)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return DismissAnimation()
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return PresentAnimation()
  }
}

final class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let key: UITransitionContextViewControllerKey = .to
    
    /* Get the controller we plan to present */
    guard let controller = transitionContext.viewController(forKey: key)
    else { return }
    
    /* Add to container */
    transitionContext.containerView.addSubview(controller.view)
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      controller.view.centerXAnchor.constraint(equalTo: transitionContext.containerView.centerXAnchor),
      controller.view.centerYAnchor.constraint(equalTo: transitionContext.containerView.centerYAnchor),
      controller.view.heightAnchor.constraint(equalTo: transitionContext.containerView.heightAnchor, multiplier: 0.5),
      controller.view.widthAnchor.constraint(equalTo: transitionContext.containerView.heightAnchor, multiplier: 0.5)
    ])
    
    /* Shrink view */
    controller.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    controller.view.alpha = 0.0
    
    let animationDuration = transitionDuration(using: transitionContext)
    UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.80, initialSpringVelocity: 0.0, options: .curveEaseOut) {
      controller.view.alpha = 1.0
      controller.view.transform = .identity
      controller.view.clipsToBounds = true
      controller.view.layer.cornerRadius = 16.0
    } completion: { finished in
      transitionContext.completeTransition(finished)
    }
  }
  
}


final class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let key: UITransitionContextViewControllerKey = .from
    
    /* Get the controller we plan to present */
    guard let controller = transitionContext.viewController(forKey: key)
    else { return }
    
    let animationDuration = transitionDuration(using: transitionContext)
    UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.67, initialSpringVelocity: 2.0, options: .curveEaseOut) {
      controller.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
      controller.view.alpha = 0.0
    } completion: { finished in
      controller.view.removeFromSuperview()
      transitionContext.completeTransition(finished)
    }
  }
  
  
}
