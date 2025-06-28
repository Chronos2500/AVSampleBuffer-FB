import SwiftUI

struct ContentView: View {
    @State private var preventsCapture: Bool = true
    var body: some View {
        // A black image should be displayed in both tabs. When preventCapture is set to true, it is expected that the content does not appear in screenshots.
        TabView {
            Tab("True", systemImage: "lock.open") {
                VCRepresentable(preventsCapture: preventsCapture)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("Prevents Capture is True")
                    .padding()
            }
            Tab("False", systemImage: "lock") {
                VCRepresentable(preventsCapture: false)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("Prevents Capture is False")
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
