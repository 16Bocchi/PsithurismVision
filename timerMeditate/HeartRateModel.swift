//
//  HeartRateModel.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 21/5/2024.
//
import Foundation
import SwiftUI
import Combine
class HeartRateModel: ObservableObject {
    @Published var heartRate: Double = 120.0 // Initial heart rate value
    private var timer: Timer?

    init() {
        startFetchingHeartRate()
  
    }
    func startFetchingHeartRate() {
        // Ensure the timer runs on the main run loop
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchHeartRateFromFirebase()
        }
    }
    func stopFetchingHeartRate() {
        timer?.invalidate()
        timer = nil
    }

    func fetchHeartRateFromFirebase() {
        let firebaseService = FirebaseService()
        firebaseService.fetchData(nodePath: "heartRates") { result in
            switch result {
            case .success(let heartRate):
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                }
            case .failure(let error):
                print("Error fetching heart rate: \(error.localizedDescription)")
            }
        }
    }

    
          
            
    
    
    
  
    deinit {
        stopFetchingHeartRate()
    }
}
