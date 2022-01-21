//
//  MessageList.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation

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
