//
//  CustomTimePickerView.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 21/5/2024.
//

import SwiftUI

struct CustomTimePickerView: View {
    @Binding var selectedTime: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Select Custom Time")
                .font(.headline)
                .padding()

            Picker("Minutes", selection: $selectedTime) {
                ForEach(1...60, id: \.self) { number in
                    Text("\(number) min")
                }
            }
            .labelsHidden()
            .pickerStyle(WheelPickerStyle())
            .frame(maxHeight: 150)

            Button("Done") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}

