//
//  UnknownStringKey.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/19/22.
//

import Foundation

/// This type will be used strictly for grabbing any `string` valued key
struct UnknownStringKey: CodingKey {
  
  var stringValue: String
  init?(stringValue: String) {
    self.stringValue = stringValue
  }
  
  var intValue: Int?
  init?(intValue: Int) {
    return nil
  }
}
