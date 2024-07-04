//
//  HeartRateGradientView.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 21/5/2024.
//

import SwiftUI

struct HeartRateGradientView: View {
    @EnvironmentObject var heartRateModel: HeartRateModel
        // Define the range for heart rate
        let minHeartRate: Double = 50.0  // Example low average heart rate
        let maxHeartRate: Double = 150.0 // Example high average heart rate

        var body: some View {
            let clampedHeartRate = min(maxHeartRate, max(minHeartRate, heartRateModel.heartRate))
            let normalizedValue = (clampedHeartRate - minHeartRate) / (maxHeartRate - minHeartRate)
            
            let gradientColor = Color(red: 1.0 - normalizedValue, green: normalizedValue, blue: 0.0)
            
            return LinearGradient(gradient: Gradient(colors: [.red, gradientColor, .green]),
                                  startPoint: .top,
                                  endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        }
}

#Preview {
    HeartRateGradientView()
}
