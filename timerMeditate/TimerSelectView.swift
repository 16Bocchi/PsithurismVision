import SwiftUI

struct TimerSelectView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var dataPass: DataPass
    
    let buttons = ["1 min", "3 min", "5 min", "Custom"]
    @State public var buttonSelected: Int = 0
    @State var selectedTimer: Int = 10
    @State public var timePass = 60
    @State private var showCustomTimePicker = false
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Time limit?")
                    .font(.title)
                    .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                
                ForEach(0..<buttons.count, id: \.self) { button in
                    Button(action: {
                        self.buttonSelected = button
                        if buttonSelected == 3 {
                            showCustomTimePicker = true
                        }
                        
                    }) {
                        Text("\(self.buttons[button])")
                            .frame(width: 100)
                        
                        
                        
                    }
                    //
                    //                    .padding()
                    .background(self.buttonSelected == button ? Color.accentColor : Color.clear)
                    //                            .foregroundColor(self.buttonSelected == button ? Color.white : Color.black)
                    .clipShape(Capsule())

                }
                NavigationLink(destination: InstructionView(dataPass: dataPass)) {
                    
                    Text("Instructions")
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.gesture(TapGesture().onEnded({
                    switch buttonSelected {
                    case 0:
                        appState.timerTime = 60
                        dataPass.timePass = 60
                    case 1:
                        appState.timerTime = 180
                        dataPass.timePass = 180
                    case 2:
                        appState.timerTime = 300
                        dataPass.timePass = 300
                    case 3:
                        appState.timerTime = selectedTimer * 60
                        dataPass.timePass = 60 * selectedTimer
                    default:
                        appState.timerTime = 60
                        dataPass.timePass = 60
                    }}))
                
            }
            .padding(70)
            
            .sheet(isPresented: $showCustomTimePicker) {
                CustomTimePickerView(selectedTime: $selectedTimer)
            }
        }
        //        .frame(width: 400, height: 400)
    }
}

//#Preview {
//    TimerSelectView(dataPass: dataPass)
//}
