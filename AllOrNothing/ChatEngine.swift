//
//  ChatEngine.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/20/22.
//

import Foundation
import Combine

protocol ChatEngineDelegate: AnyObject {
  func chatEngine(_ chatEngine: ChatEngine, emittedChatPiece piece: BotPiece)
  func chatEngine(_ chatEngine: ChatEngine, finishedConversation finished: Bool)
}

enum ChatEngineError: Error {
  case didNotStartEngine
}

final class ChatEngine {
  
  private var passthrough: CurrentValueSubject<Message, Never>!
  private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
  weak var delegate: ChatEngineDelegate?
  
  var isRunning: Bool = false
  var currentMessageID: String { passthrough.value.id }
  
  func start(initialValue: Message) {
    passthrough = CurrentValueSubject<Message, Never>(initialValue)
    passthrough
      .buffer(size: 20, prefetch: .keepFull, whenFull: .dropOldest)
      .removeDuplicates(by: { $0.id == $1.id })
      .flatMap(maxPublishers: .max(1)) { message -> AnyPublisher<BotPiece, Never> in
        var array: [BotPiece] = []
        array.append(contentsOf: message.text.map { BotPiece(id: message.id, type: .bot, text: $0, routes: message.id)})
        let combinedRepliesID = message.replies.reduce("") { result, reply -> String in
          return "\(result)|\(reply.id)"
        }
        let combinedRepliesText = message.replies.reduce("") { result, reply -> String in
          return "\(result)|\(reply.text)"
        }
        array.append(BotPiece(id: message.id, type: .user, text: combinedRepliesText, routes: combinedRepliesID))
        
        return array.publisher
          .flatMap(maxPublishers: .max(1)) {
            Just($0).delay(for: 2.0, scheduler: RunLoop.main)
          }
          .eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink { piece in
        switch piece.type {
          case .user:
            print(piece.text.components(separatedBy: "|").joined(separator: " ").trimmingCharacters(in: CharacterSet(charactersIn: " ")), piece.routes.components(separatedBy: "|").joined(separator: " ").trimmingCharacters(in: CharacterSet(charactersIn: " ")))
          case .bot:
            print(piece.text)
        }
        self.delegate?.chatEngine(self, emittedChatPiece: piece)
        
        if self.passthrough.value.tag.contains("bye") {
          self.delegate?.chatEngine(self, finishedConversation: true)
          self.passthrough.send(completion: .finished)
        }
        self.isRunning = false
      }
      .store(in: &cancellables)
  }
  
  func send(message: Message) throws {
    guard passthrough != nil else {
      throw ChatEngineError.didNotStartEngine
    }
    
    if !isRunning {
      passthrough.send(message)
      isRunning = true
    }
  }
  
  
}
