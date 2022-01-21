//
//  EndView.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation
import SwiftUI

struct EndView: View {
  var body: some View {
    VStack {
      Image(systemName: "hands.clap.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .scaleEffect(x: 0.65, y: 0.65)
      Text("You've completed the code test!")
    }
    .padding()
  }
}
