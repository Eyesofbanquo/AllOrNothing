//
//  PresentationController.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation
import UIKit

final class PresentationController: UIPresentationController {
  
  lazy var dimmingView: UIView = setupDimmingView()
  
  lazy var blurEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    blurView.alpha = 0.0
    return blurView
  }()
  
  lazy var vibrancyEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
    vibrancyView.translatesAutoresizingMaskIntoConstraints = false
    vibrancyView.alpha = 0.0
    return vibrancyView
  }()
  
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    
    /* Add dismiss on tap */
    let recognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(self.handleDismissTap(_:)))
    blurEffectView.addGestureRecognizer(recognizer)
  }
  
  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }
    containerView.insertSubview(blurEffectView, at: 0)
    
    NSLayoutConstraint.activate([
      blurEffectView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      blurEffectView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      blurEffectView.topAnchor.constraint(equalTo: containerView.topAnchor),
      blurEffectView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)])
    
    guard let coordinator = presentedViewController.transitionCoordinator else {
      blurEffectView.alpha = 1.0
      return
    }
    
    coordinator.animate { _ in
      self.blurEffectView.alpha = 1.0
    }
  }
  
  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      blurEffectView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.blurEffectView.alpha = 0.0
    })
  }
}

extension PresentationController {
  private func setupDimmingView() -> UIView {
    let dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    return dimmingView
  }
  
  @objc private func handleDismissTap(_ recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true, completion: nil)
  }
}

