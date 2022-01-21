//
//  Store.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation

enum MessageStoreError: Error {
  case didNotSetCurrentLesson
}

final class MessageStore {
  private var store: [String: Message]
  
  var messages: [String: Message] {
    store
  }
  
  init() {
    store = [:]
  }
  
  func store(messages: [String:Message], shouldReplace replace: Bool = true) {
    if replace {
      store.merge(messages) { _, new in new }
    } else {
      store.merge(messages) { old, _ in old }
    }
  }
}
