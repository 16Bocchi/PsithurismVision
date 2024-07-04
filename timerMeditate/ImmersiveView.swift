import SwiftUI
import RealityKit
import RealityKitContent
import Charts
import AVFoundation

struct ImmersiveView: View {
    @State private var modelScale: CGFloat = 1
    @ObservedObject var dataPass: DataPass

    private let targetScale: CGFloat = 9
    private let initialScale: CGFloat = 0.5
    private let growthThreshold: CGFloat = 80
    private let growthIncrement: CGFloat = 0.01
    private let shrinkIncrement: CGFloat = 0.005
    @State private var treeEntity: Entity? = nil
    @State private var playbackController: AnimationPlaybackController? = nil
    private let animationSpeed: Float = 0.03
    
    @State private var hrVals = [HeartRate]()
    @State private var count: Int = 0
    @State private var timer: Timer?
    @State private var isGrowing: Bool = false
    @State private var isShrinking: Bool = false
    @State private var latestSessionID: String?
    @EnvironmentObject var appState: AppState
    @State var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            // TreeView to display the animated tree model
            TreeView(modelScale: $modelScale, treeEntity: $treeEntity, playbackController: $playbackController, animationSpeed: animationSpeed)
                .edgesIgnoringSafeArea(.all)
            
            // Heart rate monitor chart
//            GroupBox("Heart Rate Monitor:") {
//                Chart {
//                    ForEach(hrVals) { heartRate in
//                        LineMark(x: .value("Time", heartRate.time), y: .value("Heart Rate", heartRate.rate))
//                    }
//                }
//                .chartXScale(domain: count > 20 ? [count - 20, count] : [0, 20])
//                .foregroundStyle(.red)
//            }
//            
//            // Display current heart rate
//            Text("Current heart rate: \(hrVals.last?.rate ?? 0, specifier: "%.2f") BPM")
        }
        .onAppear {
            fetchLatestSession()
            setupAudio()
        }
        .onDisappear {
            stopTimer()
            audioPlayer?.stop()
        }
        .background(
            RealityView { content in
                guard let skyBoxEntity = createSkyBox(named: dataPass.boxPass ?? "Alps") else {
                    print("Error loading skybox")
                    return
                }
                content.add(skyBoxEntity)
            }
        )
    }
    private func setupAudio() {
            if let path = Bundle.main.path(forResource: "forest-163012", ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = -1 // Set to -1 for infinite loop
                    audioPlayer?.play()
                } catch {
                    print("Error loading audio file: \(error)")
                }
            }
        }
    
    private func createSkyBox(named skyboxName: String?) -> Entity? {
        guard let skyboxName = dataPass.boxPass else {
            print("No skybox selected")
            return nil
        }
        
        let largeSphere = MeshResource.generateSphere(radius: 1000)
        var skyBoxMaterial = UnlitMaterial()
        
        do {
            let texture = try TextureResource.load(named: skyboxName)
            skyBoxMaterial.color = .init(texture: .init(texture))
        } catch {
            print("Error loading texture '\(skyboxName)': \(error.localizedDescription)")
            return nil
        }
        
        let skyBoxEntity = ModelEntity(mesh: largeSphere, materials: [skyBoxMaterial])
        skyBoxEntity.transform = Transform(scale: [1, 1, -1])
        
        return skyBoxEntity
    }
    
    private func fetchLatestSession() {
        FirebaseService().fetchAllSessionIDs { sessionIDs in
            guard let latestSessionID = sessionIDs.first else { return }
            self.latestSessionID = latestSessionID
            startTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            fetchLatestHeartRate()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchLatestHeartRate() {
        guard let sessionID = latestSessionID else { return }
        
        FirebaseService().fetchHeartRates(for: sessionID) { heartRates in
            guard let heartRates = heartRates else { return }
            DispatchQueue.main.async {
                if let latestHeartRate = heartRates.last {
                    self.hrVals.append(latestHeartRate)
                    self.count += 1
                    self.updateHeartRateBasedOnLatest(rate: latestHeartRate.rate)
                }
            }
        }
    }
    
    private func updateHeartRateBasedOnLatest(rate: Double) {
        print("Checking heart rate: \(rate)")
        if rate < Double(growthThreshold) {
            print("Heart rate \(rate) is below threshold \(growthThreshold) - incrementing tree growth")
            if !isGrowing {
                print("Starting tree growth and animation")
                isGrowing = true
                isShrinking = false
                startAnimation()
                incrementTreeGrowth()
            }
        } else {
            print("Heart rate \(rate) is above threshold \(growthThreshold) - stopping animation and shrinking tree")
            stopAnimation()
            if (!isShrinking) {
                isShrinking = true
                isGrowing = false
                decrementTreeGrowth()
            }
        }
    }
    
    private func incrementTreeGrowth() {
        print("Incrementing tree growth")
        if !isGrowing {
            print("Tree growth is stopped")
            return
        }
        let newScale = min(modelScale + growthIncrement, targetScale)
        if modelScale != newScale {
            print("Updating tree scale from \(modelScale) to \(newScale)")
            modelScale = newScale
            updateTreeScale(to: modelScale)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.isGrowing {
                    self.incrementTreeGrowth()
                }
            }
        } else {
            print("Tree has reached target scale or cannot grow further")
            isGrowing = false
        }
    }
    
    private func decrementTreeGrowth() {
        print("Decrementing tree growth")
        if !isShrinking {
            print("Tree shrinking is stopped")
            return
        }
        let newScale = max(modelScale - shrinkIncrement, initialScale)
        if modelScale != newScale {
            print("Updating tree scale from \(modelScale) to \(newScale)")
            modelScale = newScale
            updateTreeScale(to: modelScale)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if self.isShrinking {
                    self.decrementTreeGrowth()
                }
            }
        } else {
            print("Tree has reached initial scale or cannot shrink further")
            isShrinking = false
        }
    }
    
    private func updateTreeScale(to scale: CGFloat) {
        print("Updating tree scale to \(scale)")
        if let tree = treeEntity {
            let scaleVector = SIMD3<Float>(repeating: Float(scale))
            tree.move(to: Transform(scale: scaleVector), relativeTo: tree.parent, duration: 2, timingFunction: .easeInOut)
        }
    }
    
    private func startAnimation() {
        if let controller = playbackController {
            print("Starting animation")
            controller.resume()
        } else {
            print("No playback controller available to start animation")
        }
    }
    
    private func stopAnimation() {
        print("Stopping animation")
        playbackController?.pause()
        isGrowing = false
    }
    
    private func spawnNewTreeNearby() {
        Task {
            do {
                let newTree = try await Entity(named: "Working_Tree")
                await MainActor.run {
                    newTree.position = SIMD3<Float>(x: 1.0, y: 0.0, z: 1.0)
                    treeEntity?.parent?.addChild(newTree)
                }
            } catch {
                print("Error loading the new tree model: \(error)")
            }
        }
    }
}

struct TreeView: View {
    @Binding var modelScale: CGFloat
    @Binding var treeEntity: Entity?
    @Binding var playbackController: AnimationPlaybackController?
    var animationSpeed: Float
    
    var body: some View {
        RealityView { content in
            do {
                let tree = try await Entity(named: "Working_Tree")
                treeEntity = tree
                treeEntity?.scale = SIMD3<Float>(repeating: Float(modelScale))
                treeEntity?.position = SIMD3<Float>(x: 0, y: 0, z: 0)
                content.add(tree)
                
                if let animationResource = tree.availableAnimations.first {
                    playbackController = tree.playAnimation(animationResource)
                    playbackController?.speed = animationSpeed
                    print("Animation playback controller created")
                } else {
                    print("No available animations for the tree model")
                }
            } catch {
                print("Error loading the tree model: \(error)")
            }
        }
    }
}

//#Preview {
//    ImmersiveView()
//        .environmentObject(AppState())
//}
