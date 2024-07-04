import SwiftUI
import RealityKit
import RealityKitContent
import Firebase
import Charts

struct ResultScreen: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var modelScale: CGFloat = 0.0002
    private let targetScale: CGFloat = 0.008
    private let initialScale: CGFloat = 0.0002
    private let growthThreshold: Double = 80
    private let growthIncrement: CGFloat = 0.0001
    @State private var treeEntity: Entity? = nil
    @State private var playbackController: AnimationPlaybackController? = nil
    @State private var hrVals = [HeartRate]()
    @State private var count: Int = 0
    @State private var sessionIDs: [String] = []
    @State private var selectedSessionID: String? = nil

    private let firebaseService = FirebaseService()

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSessionID) {
                ForEach(sessionIDs, id: \.self) { sessionID in
                    Text("Session ID: \(sessionID)")
                        .tag(sessionID)
                }
            }
            .onAppear {
                fetchSessionIDs()
                dismissWindow(id: "BreatheScreen")
            }
        } detail: {
            VStack {
                GroupBox("Heart Rate Monitor:") {
                    if hrVals.isEmpty {
                        Text("No data available")
                            .foregroundColor(.red)
                    } else {
                        Chart(hrVals.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Heart Beats", index + 1),
                                y: .value("Heart Rate (BPM)", hrVals[index].rate)
                            )
                            .foregroundStyle(.red)
                        }
                        .chartXAxisLabel("Heart Beats")
                        .chartYAxisLabel("Heart Rate (BPM)")
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks()
                        }
                    }
                }
                .padding()
            }
            .onChange(of: selectedSessionID) { newSessionID, _ in
                if let sessionID = newSessionID {
                    fetchHeartRates(for: sessionID)
                }
            }
        }
    }

    private func fetchSessionIDs() {
        firebaseService.fetchAllSessionIDs { sessionIDs in
            DispatchQueue.main.async {
                self.sessionIDs = sessionIDs
                print("Session IDs fetched: \(self.sessionIDs)")
                if let firstSessionID = sessionIDs.first {
                    self.selectedSessionID = firstSessionID
                    fetchHeartRates(for: firstSessionID)
                }
            }
        }
    }

    private func fetchHeartRates(for sessionID: String) {
        firebaseService.fetchHeartRates(for: sessionID) { heartRates in
            DispatchQueue.main.async {
                if let heartRates = heartRates {
                    self.hrVals = heartRates.sorted(by: { $0.time < $1.time })
                    self.count = self.hrVals.count
                    print("Heart rates fetched: \(self.hrVals)")
                    self.updateHeartRateBasedOnLatest()
                } else {
                    print("No heart rate data found.")
                }
            }
        }
    }

    private func updateHeartRateBasedOnLatest() {
        guard let lastRate = hrVals.last else {
            print("No latest heart rate available.")
            return
        }
        print("Updating heart rate based on latest: \(lastRate.rate)")
    }
}

#Preview {
    ResultScreen()
}
