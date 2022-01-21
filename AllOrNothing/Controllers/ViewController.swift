//
//  ViewController.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/19/22.
//

import Combine
import UIKit

protocol ViewControllerViewDelegate {
  func viewControllerViewDelegate(_ viewDelegate: ChatViewDelegate, insertPiece piece: BotPiece, at indexPath: IndexPath)
}

class ViewController: UIViewController {
  
  var displayOnboarding: Bool = true
  lazy var endGameTransitioningDelegate = TransitioningDelegate()
  lazy var conversation: Conversation = Conversation()
  lazy var chatEngine: ChatEngine = ChatEngine()
  lazy var loader: MessageLoader = MessageLoader()
  lazy var store: MessageStore = MessageStore()
  lazy var lessonManager: LessonManager = LessonManager()
  
  var chatView: ViewControllerViewDelegate? {
    self.view as? ViewControllerViewDelegate
  }
  
  // MARK: - Lifecycle -
  
  override func loadView() {
    let chatView = ChatView()
    chatView.translatesAutoresizingMaskIntoConstraints = false
    chatView.delegate = self
    
    self.view = chatView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chatEngine.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard displayOnboarding else { return }
    let onboardingViewController = ViewPresenter(rootView: OnboardingView(delegate: self))
    self.present(onboardingViewController, animated: true) {
      self.displayOnboarding = false
    }
  }
}

extension ViewController: ChatEngineDelegate {
  func chatEngine(_ chatEngine: ChatEngine, emittedChatPiece piece: BotPiece) {
    self.conversation.add(piece: piece)
    let newIndexPath = IndexPath(row: self.conversation.numberOfItems() - 1 < 0 ? 0 : self.conversation.numberOfItems() - 1, section: 0)
    chatView?.viewControllerViewDelegate(self, insertPiece: piece, at: newIndexPath)
  }
}

extension ViewController: ChatPieceTableViewCellDelegate {
  func chatPieceDelegate(chatPieceCell: ChatPieceTableViewCell, didSelectAnswerChoice choiceId: String) {
    guard let message = lessonManager.lesson[choiceId] else { return }
    do {
      if chatEngine.state == .ended {
        let endController = ViewPresenter(rootView: EndView())
        endController.modalPresentationStyle = .custom
        endController.transitioningDelegate = endGameTransitioningDelegate
        self.present(endController, animated: true)
      } else {
        try chatEngine.send(message: message)
      }
    } catch {
      print(error)
    }
  }
  
  func chatEngine(_ chatEngine: ChatEngine, finishedConversation finished: Bool) {
    guard chatEngine.state == .ended else { return }
    
    print("We're done")
  }
}

extension ViewController: ChatViewDelegate {
  func setChatPieceCellDelegate(chatPieceCell: inout ChatPieceTableViewCell, forPiece piece: BotPiece) {
    guard piece.type == .user else {
      chatPieceCell.delegate = nil
      return
    }
    chatPieceCell.delegate = chatEngine.currentMessageID == piece.id ? self : nil
  }
  
  var currentMessageID: String {
    chatEngine.currentMessageID
  }
  
  func retrievePiece(atIndex index: IndexPath) -> BotPiece? {
    conversation[index.row]
  }
  
  var numberOfConversationPieces: Int {
    conversation.numberOfItems()
  }
}

extension ViewController: OnboardingViewDelegate {
  func begin() {
    do {
      let loadedMessages = try loader.load(fromPath: "allornothing", ofType: "json")
      store.store(messages: loadedMessages, shouldReplace: true)
      lessonManager.set(lesson: .allOrNothing, fromStore: store)
      let firstMessage = try lessonManager.retrieveStartOfLesson()
      try chatEngine.start(initialValue: firstMessage)
    } catch {
      /* Handle errors here with starting a lesson */
      print(error)
    }
  }
}
