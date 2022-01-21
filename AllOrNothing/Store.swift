//
//  Store.swift
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

enum Lesson: String {
  case allOrNothing = "allornothing"
}

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

enum LessonManagerError: Error {
  case lessonDoesNotStart
  case lessonIsEmpty
  case invalidLesson
}

final class LessonManager {
  private(set) var lesson: [String: Message]
  
  func retrieveStartOfLesson() throws -> Message {
    guard lesson.isEmpty == false else {
      throw LessonManagerError.lessonIsEmpty
    }
    guard let firstMessage = lesson.first(where: { $0.value.tag.contains("start")})?.value else {
      throw LessonManagerError.lessonDoesNotStart
    }
    guard lesson.first(where: { $0.value.tag.contains("bye")}) != nil else {
      throw LessonManagerError.invalidLesson
    }
    return firstMessage
  }
  
  init(lesson: [String: Message] = [:]) {
    self.lesson = lesson
  }
  
  func set(lesson: Lesson, fromStore store: MessageStore) {
    self.lesson = store.messages.filter { $0.value.lesson.lowercased() == lesson.rawValue.lowercased() }
  }
}
