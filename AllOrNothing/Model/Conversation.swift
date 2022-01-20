//
//  Conversation.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/20/22.
//

import Foundation

class Conversation {
  private var conversation: [BotPiece]
  
  init() {
    conversation = []
  }
  
  func add(piece: BotPiece) {
    self.conversation.append(piece)
  }
  
  func numberOfItems() -> Int {
    return conversation.count
  }
  
  subscript(index: Int) -> BotPiece? {
    get {
      guard index > -1 && index < conversation.count else { return nil }
      return conversation[index]
    }
    set(newValue) { }
  }
}
