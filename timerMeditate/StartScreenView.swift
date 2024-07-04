import SwiftUI

struct StartScreenView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @StateObject var appState = AppState()
    @ObservedObject var dataPass: DataPass
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Psithurism!")
                    .font(.title)
                Image(systemName: "tree.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                Spacer()
                NavigationLink(destination: ImmersiveSelectView(dataPass: dataPass)) {
                    Text("Launch")
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button {
                    openWindow(id: "ResultScreen")
                } label: {
                    Text("Recall")
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

            }
            .padding(50)
            
        }
        .environmentObject(appState)
//        .frame(width: 400, height: 400)
    }
}

//#Preview {
//    StartScreenView()
//}
