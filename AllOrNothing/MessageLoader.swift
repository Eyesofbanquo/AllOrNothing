//
//  MessageLoader.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation

enum MessageLoaderError: Error {
  case invalidJSON
  case decodingError(error: Error)
}

final class MessageLoader {
  func load(fromPath path: String, ofType type: String) throws -> [String: Message] {
    let json = Bundle.main.path(forResource: path, ofType: type)
    do {
      guard let validJSONString = json else {
        throw MessageLoaderError.invalidJSON
      }
      let data = try Data(contentsOf: URL(fileURLWithPath: validJSONString), options: .mappedIfSafe)
      let messageList = try JSONDecoder().decode(MessageList.self, from: data)
      return messageList.messages
    } catch {
      throw MessageLoaderError.decodingError(error: error)
    }
  }
}
