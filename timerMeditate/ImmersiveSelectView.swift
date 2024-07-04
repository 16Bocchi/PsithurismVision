import SwiftUI

struct ImmersiveSelectView: View {
    @ObservedObject var dataPass: DataPass

    @EnvironmentObject var appState: AppState
//    @ObservedObject var appState: AppState
    @State private var selectedSkybox: Int = 0
    private let skyboxes = ["Alps", "Meadow", "Forest"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Where would you rather be?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                ForEach(0..<skyboxes.count, id: \.self) { button in
                    Button(action: {
                        self.selectedSkybox = button
                        self.appState.selectedSkybox = skyboxes[button]
                        dataPass.boxPass = skyboxes[button]
                        
                        print("Selected Skybox: \(skyboxes[button])") // Debugging print
                    }) {
                        Text("\(self.skyboxes[button])")
                            .frame(width: 100)
                    }
                    .background(self.selectedSkybox == button ? Color.accentColor : Color.clear)
                    .clipShape(Capsule())
                }
                
                NavigationLink(destination: TimerSelectView(dataPass: dataPass)) {
                    Text("Next")
                }
            }
            .padding(50)
        }
    }
}

//#Preview {
//    ImmersiveSelectView()
//        .environmentObject(AppState())
//}
