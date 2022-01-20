//
//  Message.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/19/22.
//

import Foundation

struct MessageReply: Decodable {
  var id: String
  var text: String
}
struct Message: Decodable {
  var id: String
  var text: [String]
//  var replies: [String]
  var payloads: [String]
//  var routes: [String]
  var tag: String
  var lesson: String
  var replies: [MessageReply]
  
  enum CodingKeys: String, CodingKey {
    case id, text, replies, payloads, routes, tag, lesson
  }
}

extension Message {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    
    let textString = try container.decode(String.self, forKey: .text)
    self.text = textString.components(separatedBy: "|")
    
    let repliesArray = Self.stringOrArray([String].self, forKey: .replies, in: container)
    let routesArray = Self.stringOrArray([String].self, forKey: .routes, in: container)
    let zippedArray = zip(routesArray, repliesArray)
    self.replies = zippedArray.map { MessageReply(id: $0, text: $1) }
    
    self.payloads = Self.stringOrArray([String].self, forKey: .payloads, in: container)
    self.tag = try container.decode(String.self, forKey: .tag)
    self.lesson = try container.decode(String.self, forKey: .lesson)
  }
  
  private static func stringOrArray<T: Decodable>(_ U: [T].Type, forKey key: CodingKeys, in container: KeyedDecodingContainer<Message.CodingKeys>) -> [T] {
    if let repliesString = try? container.decode(T.self, forKey: key) {
      return [repliesString]
    } else if let repliesArray = try? container.decode(U, forKey: key)  {
      return repliesArray
    } else {
      return []
    }
  }
}
