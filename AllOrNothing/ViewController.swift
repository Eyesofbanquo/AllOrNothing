//
//  ViewController.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/19/22.
//

import Combine
import UIKit

struct MessageList: Decodable {
  var messages: [String: Message]
}

extension MessageList {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: UnknownStringKey.self)
    self.messages = [:]
    for key in container.allKeys {
      self.messages[key.stringValue] = try container.decode(Message.self, forKey: key)
    }
  }
}


class ViewController: UIViewController {
  
  /* Should be in a loader */
  private(set) var messages: [String: Message] = [:]
  var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
  lazy var passthrough = PassthroughSubject<Message, Never>()
  lazy var tableView: UITableView = {
    let tv = UITableView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.backgroundColor = .init(hexString: "#CCDBDC")
    tv.separatorStyle = .none
    tv.register(ChatPieceTableViewCell.self,
                forCellReuseIdentifier: ChatPieceTableViewCell.reuseIdentifier)
    return tv
  }()
  lazy var conversation: Conversation = Conversation()
  lazy var chatEngine: ChatEngine = ChatEngine()
  
  // MARK: - Lifecycle -
  
  override func loadView() {
    let backgroundView = UIView()
    backgroundView.backgroundColor = .init(hexString: "#CCDBDC")
    
    backgroundView.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
      
      tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
      
      tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.topAnchor, constant: 8.0),
      
      tableView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -8.0)
    ])
    
    
    self.view = backgroundView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /* Hook up table view */
    //    tableView.delegate = self
    tableView.dataSource = self
    chatEngine.delegate = self
    
    /* Decode Messages */
    let json = Bundle.main.path(forResource: "allornothing", ofType: "json")
    do {
      guard let validJSONString = json else { return }
      let data = try Data(contentsOf: URL(fileURLWithPath: validJSONString), options: .mappedIfSafe)
      let messageList = try JSONDecoder().decode(MessageList.self, from: data)
      self.messages = messageList.messages
    } catch {
      print(error)
    }
    
    chatEngine.start(initialValue: messages["EIC"]!)
  }
  
  
}

extension ViewController: ChatEngineDelegate {
  func chatEngine(_ chatEngine: ChatEngine, emittedChatPiece piece: BotPiece) {
    self.conversation.add(piece: piece)
    self.tableView.beginUpdates()
    self.tableView.insertRows(at: [IndexPath(row: self.conversation.numberOfItems() - 1 < 0 ? 0 : self.conversation.numberOfItems() - 1, section: 0)], with: .top)
    
    self.tableView.endUpdates()
    self.tableView.scrollToRow(at: IndexPath(row: self.conversation.numberOfItems() - 1 < 0 ? 0 : self.conversation.numberOfItems() - 1, section: 0), at: .top, animated: true)
  }
}

extension ViewController: ChatPieceTableViewCellDelegate {
  func chatPieceDelegate(chatPieceCell: ChatPieceTableViewCell, didSelectAnswerChoice choiceId: String) {
    guard let message = messages[choiceId] else { return }
    do {
      try chatEngine.send(message: message)
    } catch {
      print(error)
    }
  }
  
  func chatEngine(_ chatEngine: ChatEngine, finishedConversation finished: Bool) {
    print("We're done")
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChatPieceTableViewCell.reuseIdentifier, for: indexPath)
    cell.contentView.isUserInteractionEnabled = false
    cell.selectionStyle = .none
    guard let chatPieceCell = cell as? ChatPieceTableViewCell,
          let piece = conversation[indexPath.row] else { return cell }
    
    chatPieceCell.configure(usingPiece: piece)
    /* only add delegate if current id | remove if not*/
    chatPieceCell.delegate = chatEngine.currentMessageID == piece.id ? self : nil
    return chatPieceCell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversation.numberOfItems()
  }
}

