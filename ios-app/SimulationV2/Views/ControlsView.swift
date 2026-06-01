import SwiftUI

/// Playback controls: run/pause, single step, reset, speed and seed.
struct ControlsView: View {
    @ObservedObject var engine: SimulationEngine

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button {
                    engine.toggleRun()
                } label: {
                    Label(engine.isRunning ? "Пауза" : "Запуск",
                          systemImage: engine.isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(engine.isFinished)

                Button {
                    engine.step()
                } label: {
                    Label("Крок", systemImage: "forward.frame.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(engine.isFinished || engine.isRunning)
            }

            Button(role: .destructive) {
                engine.reset()
            } label: {
                Label("Скинути", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Швидкість")
                    Spacer()
                    Text("\(Int(engine.ticksPerSecond)) tick/с")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Slider(value: $engine.ticksPerSecond, in: 1...20, step: 1)
            }

            Stepper(value: $engine.seed, in: 0...9999) {
                HStack {
                    Text("Seed")
                    Spacer()
                    Text("\(engine.seed)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .onChange(of: engine.seed) { _, _ in
                // Changing the seed re-seeds and restarts the run (PHYSICS §5.1).
                engine.reset()
            }
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
}
