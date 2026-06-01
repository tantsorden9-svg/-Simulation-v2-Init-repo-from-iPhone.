import SwiftUI

/// Scrollback of the most recent simulation log entries (PHYSICS.md §6).
struct LogView: View {
    let entries: [LogEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Журнал", systemImage: "list.bullet.rectangle")
                .font(.headline)

            if entries.isEmpty {
                Text("Подій ще немає.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entries.suffix(8).reversed()) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        Text("t\(entry.tick)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.tint)
                            .frame(width: 36, alignment: .leading)
                        Text(entry.message)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
}
