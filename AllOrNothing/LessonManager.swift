//
//  LessonManager.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation

enum Lesson: String {
  case allOrNothing = "allornothing"
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
