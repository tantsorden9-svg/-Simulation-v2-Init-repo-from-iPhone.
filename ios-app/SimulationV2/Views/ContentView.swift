import SwiftUI

struct ContentView: View {
    @StateObject private var engine = SimulationEngine()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    StatsView(engine: engine)
                    GridView(engine: engine)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.horizontal)
                    ControlsView(engine: engine)
                    LogView(entries: engine.log)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Simulation v2")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
