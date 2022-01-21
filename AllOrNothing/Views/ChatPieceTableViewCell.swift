//
//  ChatPieceTableViewCell.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/20/22.
//

import Foundation
import UIKit

protocol ChatPieceTableViewCellDelegate: AnyObject {
  func chatPieceDelegate(chatPieceCell: ChatPieceTableViewCell, didSelectAnswerChoice choiceId: String)
}

final class ChatPieceTableViewCell: UITableViewCell {
  static var reuseIdentifier: String = "ChatPieceTableViewCell"
  
  private var containerView: UIView = UIView()
  private var contentStackView: UIStackView = UIStackView()
  private var scrollView: UIScrollView = UIScrollView()
  private var label: UILabel = UILabel()
  private var type: ChatPieceType!
  
  weak var delegate: ChatPieceTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    containerView.translatesAutoresizingMaskIntoConstraints = false
    contentStackView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    
    contentStackView.axis = .horizontal
    contentStackView.spacing = 4.0
    contentStackView.alignment = .center
    contentStackView.distribution = .fillProportionally
    
    scrollView.addSubview(contentStackView)
    containerView.addSubview(scrollView)
    self.addSubview(containerView)
    
    NSLayoutConstraint.activate(ScrollConstraints)
  }
  
  override func prepareForReuse() {
    containerView.backgroundColor = .clear
    label.text = ""
    contentStackView.arrangedSubviews.forEach { view in
      contentStackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
    guard type != nil else { return }
    switch type! {
    case .user:
        NSLayoutConstraint.deactivate(UserBubbleConstraints)
        NSLayoutConstraint.deactivate(ContentStackViewConstraintsScroll)
    case .bot:
        label.removeFromSuperview()
        NSLayoutConstraint.deactivate(BotBubbleConstraints)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  lazy var ContentStackViewConstraints: [NSLayoutConstraint] = [
    contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
    contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
    contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
    contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0),
  ]
  
  lazy var ContentStackViewConstraintsScroll: [NSLayoutConstraint] = [
    contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
    contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
    contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
    contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
    contentStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
  ]
  
  lazy var ScrollConstraints: [NSLayoutConstraint] = [
    scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
    scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
    scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
  ]
  
  lazy var WidthConstraint: NSLayoutConstraint = {
    let widthConstraint = containerView.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width * 0.80)
    widthConstraint.priority = .required
    return widthConstraint
  }()
  
  lazy var UserBubbleConstraints = [
    containerView.widthAnchor.constraint(equalToConstant: bounds.width * 0.80),
    containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -4.0),
    containerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4.0),
    containerView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -4.0)
  ]
  
  lazy var BotBubbleConstraints = [
    label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
    label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
    label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
    label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0),
    WidthConstraint,
    containerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 4.0),
    containerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4.0),
    containerView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -4.0)
  ]
  
  func configure(usingPiece piece: BotPiece) {
    self.type = piece.type
    switch piece.type {
      case .user:
        NSLayoutConstraint.activate(UserBubbleConstraints)
        NSLayoutConstraint.activate(ContentStackViewConstraintsScroll)
        for (index, reply) in piece.textArray.enumerated() {
          var config = UIButton.Configuration.filled()
          config.baseBackgroundColor = .init(hexString: "#63C7B2")
          config.background.cornerRadius = 4.0
          config.title = reply
          config.titleAlignment = .automatic
          config.baseForegroundColor = .white
          let button = UIButton()
          button.configuration = config
          button.isSelected = false
          button.addAction(UIAction(handler: { action in
            guard piece.routesArray.isEmpty == false else { return }
            self.delegate?.chatPieceDelegate(chatPieceCell: self, didSelectAnswerChoice: piece.routesArray[index])
          }), for: .touchUpInside)
          
          contentStackView.addArrangedSubview(button)
        }
      case .bot:
        containerView.addSubview(label)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 4.0
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
        label.text = piece.text
        label.textColor = .black
        NSLayoutConstraint.activate(BotBubbleConstraints)
    }
    
  }
}
