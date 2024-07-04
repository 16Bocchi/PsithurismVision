//
//  timerMeditateApp.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 13/5/2024.
//

import SwiftUI
import HealthKit

class DataPass: ObservableObject{
    @Published var timePass:Int? = 60
    @Published var boxPass:String? = "Alps"
}

@main
struct timerMeditateApp: App {
    @StateObject var dataPass = DataPass()
    @StateObject private var heartRateModel = HeartRateModel()
    @StateObject var appState = AppState()
    @State var timeRem: Int? = 60
    
    public var selectBox: String? = "Alps"
    @State var immersionMode:ImmersionStyle = .progressive


    var body: some Scene {
        WindowGroup(id: "StartScreen") {
            StartScreenView(dataPass: dataPass)
                .environmentObject(heartRateModel)
                .environmentObject(appState)
        }
        .defaultSize(width: 500, height: 400)
        WindowGroup(id: "TimerScreen") {
            TimerSelectView(dataPass: dataPass)
                .environmentObject(heartRateModel)
                .environmentObject(appState)
        }
        .defaultSize(width: 500, height: 500)
        WindowGroup(id: "BreatheScreen") {
            BreatheView(dataPass: dataPass)
                .environmentObject(heartRateModel)
                .environmentObject(appState)
        }
        .defaultSize(width: 500, height: 400)
        WindowGroup(id: "EnvSelectScreen") {
            ImmersiveSelectView(dataPass: dataPass)
                .environmentObject(appState)
        }
        .defaultSize(width: 500, height: 400)
        WindowGroup(id: "ResultScreen"){
            ResultScreen()
        }
        ImmersiveSpace(id: "ImmersiveView") {
            ImmersiveView(dataPass: dataPass)
                .environmentObject(appState)
        }.immersionStyle(selection: $immersionMode, in: .full)
    }
       
}
