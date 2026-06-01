import SwiftUI

/// Top status panel: tick counter, distance to goal and current run status.
struct StatsView: View {
    @ObservedObject var engine: SimulationEngine

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                metric(title: "Tick",
                       value: "\(engine.tick)/\(engine.world.rules.maxTicks)",
                       systemImage: "clock")
                metric(title: "Відстань",
                       value: "\(engine.distanceToGoal)",
                       systemImage: "ruler")
                metric(title: "Seed",
                       value: "\(engine.seed)",
                       systemImage: "dice")
            }

            HStack(spacing: 8) {
                Image(systemName: engine.statusSymbol)
                    .foregroundStyle(engine.statusColor)
                Text(engine.status.rawValue)
                    .fontWeight(.semibold)
                Spacer()
                Text(engine.world.meta.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private func metric(title: String, value: String, systemImage: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .foregroundStyle(.tint)
            Text(value)
                .font(.title3.weight(.bold))
                .monospacedDigit()
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
