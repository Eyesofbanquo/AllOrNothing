//
//  ChatView.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation
import UIKit

protocol ChatViewDelegate: AnyObject {
  var numberOfConversationPieces: Int { get }
  var currentMessageID: String { get }
  func retrievePiece(atIndex index: IndexPath) -> BotPiece?
  func setChatPieceCellDelegate(chatPieceCell: inout ChatPieceTableViewCell, forId id: String)
}

final class ChatView: UIView {
  
  var tableView: UITableView
  
  weak var delegate: ChatViewDelegate?
  
  init() {
    let backgroundView = UIView()
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.backgroundColor = .init(hexString: "#CCDBDC")
    
    let tv = UITableView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.backgroundColor = .init(hexString: "#CCDBDC")
    tv.separatorStyle = .none
    tv.register(ChatPieceTableViewCell.self,
                forCellReuseIdentifier: ChatPieceTableViewCell.reuseIdentifier)
    
    tableView = tv
    
    super.init(frame: .zero)
    
    backgroundView.addSubview(tableView)
    backgroundColor = .init(hexString: "#CCDBDC")
    addSubview(backgroundView)
    NSLayoutConstraint.activate([
      tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
      tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
      tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.topAnchor, constant: 8.0),
      tableView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      backgroundView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
      backgroundView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
      backgroundView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
      backgroundView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    tableView.dataSource = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ChatView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.delegate?.numberOfConversationPieces ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChatPieceTableViewCell.reuseIdentifier, for: indexPath)
    cell.contentView.isUserInteractionEnabled = false
    cell.selectionStyle = .none
    guard var chatPieceCell = cell as? ChatPieceTableViewCell,
          let piece = delegate?.retrievePiece(atIndex: indexPath) else { return cell }
    
    chatPieceCell.configure(usingPiece: piece)
    delegate?.setChatPieceCellDelegate(chatPieceCell: &chatPieceCell, forId: piece.id)
    return chatPieceCell
  }
  
  
}

extension ChatView: ViewControllerViewDelegate {
  func viewControllerViewDelegate(_ viewDelegate: ChatViewDelegate,
                                  insertPiece piece: BotPiece,
                                  at indexPath: IndexPath) {
    self.tableView.beginUpdates()
    self.tableView.insertRows(at: [indexPath], with: .top)
    
    self.tableView.endUpdates()
    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
  }
}
