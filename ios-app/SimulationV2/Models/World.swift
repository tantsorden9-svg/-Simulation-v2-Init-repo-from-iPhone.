import Foundation

/// A cell coordinate on the discrete grid.
struct GridPosition: Equatable, Hashable, Codable {
    var x: Int
    var y: Int

    func manhattanDistance(to other: GridPosition) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
}

/// Entity types allowed by PHYSICS.md §3 / TEMPLATE_WORLD.yaml.
enum EntityKind: String, Codable {
    case agent
    case object
    case zone
}

/// A single entity living inside a world.
///
/// `props` holds numeric attributes (speed, vision_range, move_prob, …) while
/// `tags` holds string attributes (e.g. `type: "goal"`), mirroring the loose
/// `props` block from the YAML world definitions.
struct Entity: Identifiable, Codable {
    let id: String
    let kind: EntityKind
    var position: GridPosition
    var props: [String: Double]
    var tags: [String: String]

    var isGoal: Bool { tags["type"] == "goal" }

    init(id: String,
         kind: EntityKind,
         position: GridPosition,
         props: [String: Double] = [:],
         tags: [String: String] = [:]) {
        self.id = id
        self.kind = kind
        self.position = position
        self.props = props
        self.tags = tags
    }
}

/// A serialised world — the §4 "world_state" contract for a SIM.
struct World: Codable {
    var meta: Meta
    var width: Int
    var height: Int
    var entities: [Entity]
    var rules: Rules

    struct Meta: Codable {
        var id: String
        var name: String
        var simId: String
        var physicsVersion: String
        var description: String

        enum CodingKeys: String, CodingKey {
            case id, name, description
            case simId = "sim_id"
            case physicsVersion = "physics_version"
        }
    }

    struct Rules: Codable {
        var maxTicks: Int
        var stopConditions: [String]

        enum CodingKeys: String, CodingKey {
            case maxTicks = "max_ticks"
            case stopConditions = "stop_conditions"
        }
    }

    /// First agent entity (the moving subject of the simulation).
    var agent: Entity? { entities.first { $0.kind == .agent } }

    /// The goal object the agent is trying to reach.
    var goal: Entity? { entities.first { $0.isGoal } }

    /// Clamp a position to the grid bounds.
    func clamp(_ p: GridPosition) -> GridPosition {
        GridPosition(x: min(max(p.x, 0), width - 1),
                     y: min(max(p.y, 0), height - 1))
    }

    /// In-bounds 4-neighbours of a cell.
    func neighbours(of p: GridPosition) -> [GridPosition] {
        let candidates = [
            GridPosition(x: p.x + 1, y: p.y),
            GridPosition(x: p.x - 1, y: p.y),
            GridPosition(x: p.x, y: p.y + 1),
            GridPosition(x: p.x, y: p.y - 1)
        ]
        return candidates.filter {
            $0.x >= 0 && $0.x < width && $0.y >= 0 && $0.y < height
        }
    }
}
