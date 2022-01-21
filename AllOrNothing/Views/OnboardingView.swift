//
//  OnboardingView.swift
//  AllOrNothing
//
//  Created by Markim Shaw on 1/21/22.
//

import Foundation
import SwiftUI

protocol OnboardingViewDelegate {
  func begin()
}

struct OnboardingView: View {
  
  enum OnboardingViews: CaseIterable {
    case time, love, cap
    
    var imageName: String {
      switch self {
        case .time: return "timer"
        case .love: return "suit.heart.fill"
        case .cap: return "graduationcap.fill"
      }
    }
    
    var description: String {
      switch self {
        case .time:
          return "This took a little longer than 3-5 hours but I put a lot of fun and effort into this project and I'm currently pleased with the results ☺️"
        case .love:
          return "Fun + Effort = ❤️. Hopefully that is reflected in the design patterns/philosophies that I implemented. Favorite part of this test? Check out ChatEngine.swift 😎"
        case .cap:
          return "Without further ado... simply dismiss this view to begin your conversation with the AllOrNothing instructor 🤓"
      }
    }
  }
  
  @State var delegate: OnboardingViewDelegate?
  
  init(delegate: OnboardingViewDelegate) {
    _delegate = State(initialValue: delegate)
  }
  
  var body: some View {
    ZStack {
      Color(uiColor: .init(hexString: "#CCDBDC"))
        .ignoresSafeArea()
      
      VStack {
        Spacer()
        Text("All or Nothing")
          .font(.largeTitle)
          .bold()
        
        Spacer()
        VStack(alignment: .leading, spacing: 8.0) {
          ForEach(OnboardingViews.allCases, id: \.self) { view in
            HStack(alignment: .center, spacing: 8.0) {
              Image(systemName: view.imageName)
                .foregroundColor(Color(uiColor: .init(hexString: "#8E6C88")))
              Text(view.description)
                .font(.caption)
              Spacer()
            }
            .padding()
            
          }
        }
        
        Spacer()
        Spacer()
      }
      .padding()
      .onDisappear {
        self.delegate?.begin()
      }
    }
    
  }
}
