import Foundation

/// Loads world definitions.
///
/// Mirrors PHYSICS.md §6: a SIM can receive external inputs (here a bundled
/// JSON world that matches `sim/sim-002_world/world.yaml`). If the resource is
/// missing or malformed we fall back to an equivalent in-code definition so the
/// app always launches into a valid state.
enum WorldLoader {
    static func loadDefault() -> World {
        if let url = Bundle.main.url(forResource: "world-sim002", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let world = try? JSONDecoder().decode(World.self, from: data) {
            return world
        }
        return builtInSIM002
    }

    /// Code fallback equivalent to `world-sim002.json` / SIM-002.
    static let builtInSIM002 = World(
        meta: .init(
            id: "world-001",
            name: "Test World v1",
            simId: "SIM-002",
            physicsVersion: "0.1",
            description: "Мінімальний тестовий світ для перевірки структури."
        ),
        width: 8,
        height: 8,
        entities: [
            Entity(
                id: "agent-001",
                kind: .agent,
                position: GridPosition(x: 0, y: 0),
                props: ["speed": 1, "vision_range": 2, "move_prob": 0.85]
            ),
            Entity(
                id: "goal-001",
                kind: .object,
                position: GridPosition(x: 7, y: 7),
                tags: ["type": "goal"]
            )
        ],
        rules: .init(maxTicks: 50, stopConditions: ["reached_goal", "max_ticks"])
    )
}
