//
//  AppState.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 23/5/2024.
//


import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isBreatheViewActive: Bool = false
    @Published var selectedSkybox: String? = "Alps"  // Add this property
    @Published var timerTime: Int? = 60
}
//#Preview {
//    BreatheView(timeRemaining: 50)
//        .environmentObject(HeartRateModel())
//        .environmentObject(AppState())
//}

// Preview integration for ImmersiveSelectView
//#Preview {
//    ImmersiveSelectView()
//        .environmentObject(AppState())
//}

