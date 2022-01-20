//
//  BotPiece.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/20/22.
//

import Foundation

struct BotPiece {
  var id: String
  var type: ChatPieceType
  var text: String
  var routes: String
  
  var textArray: [String] {
    text.components(separatedBy: "|").filter({ $0.isEmpty == false })
  }
  
  var routesArray: [String] {
    routes.components(separatedBy: "|").filter({ $0.isEmpty == false })
  }
}
