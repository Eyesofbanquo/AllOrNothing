//
//  EndViewController.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation
import UIKit
import SwiftUI

final class ViewPresenter<Content>: UIViewController where Content: View {
  
  var rootView: Content
  init(rootView: Content) {
    self.rootView = rootView
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let hostingController = UIHostingController(rootView: rootView)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChild(hostingController)
    self.view.addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    hostingController.didMove(toParent: self)
  }
}
