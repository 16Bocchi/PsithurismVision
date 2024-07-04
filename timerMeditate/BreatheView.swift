import SwiftUI
import RealityKit

struct BreatheView: View {
    @ObservedObject var dataPass: DataPass
    
    @State public var timeRemaining = 50
    @State private var firstTime = true
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @EnvironmentObject var heartRateModel: HeartRateModel
    @EnvironmentObject var appState: AppState
    @State public var startAnimation = true
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var immersiveSpaceIsShown = false

    var body: some View {
        
        ZStack {
            ForEach(0..<5, id: \.self) { circleSetNumber in
                let rotationAngle = Double(circleSetNumber * 36)
                
                ZStack {
                    Circle()
                        .fill(gradientColor(for: heartRateModel.heartRate))
                        .frame(width: 150, height: 150)
                        .offset(y: startAnimation ? 150 : 0)
                        .rotation3DEffect(.degrees(startAnimation ? rotationAngle : 0), axis: (x: 1, y: 1, z: 1))
                    
                    Circle()
                        .fill(gradientColor(for: heartRateModel.heartRate))
                        .frame(width: 150, height: 150)
                        .offset(y: startAnimation ? -150 : 0)
                        .rotation3DEffect(.degrees(startAnimation ? -rotationAngle : 0), axis: (x: -1, y: -1, z: -1))
                }
                .opacity(0.7)
                .scaleEffect(startAnimation ? 1 : 0.2)
                .onAppear {
                    
                    withAnimation(Animation.easeInOut(duration: 4).delay(2).repeatForever(autoreverses: true)) {
                        startAnimation.toggle()

                    }
//                    Task {
//                        if firstTime{
//                            firstTime = false
//                            let result = await openImmersiveSpace(id: "ImmersiveView")
//                            immersiveSpaceIsShown = true
//                            if case .error = result {
//                                print("An error occurred")
//                            }
//                        }
//                    }
                }
                
            }
        }

        .onAppear(){
            dismissWindow(id: "TimerScreen")
            dismissWindow(id: "StartScreen")
            timeRemaining = dataPass.timePass ?? 60
            Task{
                if firstTime{
                    firstTime = false
                    await openImmersiveSpace(id: "ImmersiveView")
                }
            }
        }
        .onDisappear(){
            timer.upstream.connect().cancel()
            openWindow(id: "StartScreen")

        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                print(timeRemaining)
                timeRemaining -= 1
            } else {
                immersiveSpaceIsShown = false
                timeRemaining = 1000000
                timer.upstream.connect().cancel()
                openWindow(id: "ResultScreen")
                dismissWindow(id: "StartScreen")
                
                // Handle end of timer, perhaps navigate back or show a message
            }
        }
        .onChange(of: immersiveSpaceIsShown){_, newValue in
            Task {
                if !newValue{
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
            
        }
        .frame(width: 500, height: 500)
    }
    
    func gradientColor(for heartRate: Double, minHeartRate: Double = 60.0, maxHeartRate: Double = 100.0) -> LinearGradient {
        let clampedHeartRate = min(maxHeartRate, max(minHeartRate, heartRate))
        let normalizedValue = (clampedHeartRate - minHeartRate) / (maxHeartRate - minHeartRate)
        
        let gradientColor = Color(red: normalizedValue, green: 1.0 - normalizedValue, blue: 0.0)
        
        return LinearGradient(
            gradient: Gradient(colors: [.green, gradientColor, .red]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

//#Preview {
//    BreatheView(timeRemaining: 50)
//        .environmentObject(HeartRateModel())
//        .environmentObject(AppState())
//}
