//
//  InstructionView.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 28/5/2024.
//

import SwiftUI

struct InstructionView: View {
    @ObservedObject var dataPass: DataPass
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        VStack{
            Text("Instructions:")
                .font(.title)
            Text("Match your breathing to the circle patterns")
            Text("Breath in to expand")
            Text("Breathe out to release")
            Button {
                openWindow(id: "BreatheScreen")
                dismissWindow()
            } label: {
                Text("Start")
                    .padding()
            }

        }
        
    }
}

//#Preview {
//    InstructionView()
//}
