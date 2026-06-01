import Foundation
import SwiftUI

/// A single line in the simulation log (PHYSICS.md §6 — logging/metrics output).
struct LogEntry: Identifiable {
    let id = UUID()
    let tick: Int
    let message: String
}

/// The tick-based simulation engine.
///
/// Implements the PHYSICS.md update cycle (§2, §5):
///   1. read current state,
///   2. apply update rules,
///   3. produce state for tick `t+1`.
///
/// The agent greedily walks towards the goal with a seed-controlled stochastic
/// exploration term, so the whole run is reproducible from `(world, seed)`.
@MainActor
final class SimulationEngine: ObservableObject {

    enum Status: String {
        case idle = "Готово"
        case running = "Виконується"
        case reachedGoal = "Ціль досягнута"
        case maxTicks = "Ліміт тіків"
    }

    @Published private(set) var world: World
    @Published private(set) var tick: Int = 0
    @Published private(set) var status: Status = .idle
    @Published private(set) var trail: [GridPosition] = []
    @Published private(set) var log: [LogEntry] = []

    @Published var isRunning: Bool = false
    @Published var ticksPerSecond: Double = 4 {
        didSet { if isRunning { scheduleTimer() } }
    }
    @Published var seed: Int

    private let initialWorld: World
    private var rng: SeededGenerator
    private var timer: Timer?

    init(world: World = WorldLoader.loadDefault(), seed: Int = 42) {
        self.world = world
        self.initialWorld = world
        self.seed = seed
        self.rng = SeededGenerator(seed: UInt64(max(seed, 0)))
        appendLog("SIM \(world.meta.simId) «\(world.meta.name)» завантажено (\(world.width)×\(world.height)).")
    }

    // MARK: - Derived state

    var isFinished: Bool { status == .reachedGoal || status == .maxTicks }

    var distanceToGoal: Int {
        guard let a = world.agent, let g = world.goal else { return 0 }
        return a.position.manhattanDistance(to: g.position)
    }

    var statusSymbol: String {
        switch status {
        case .idle: return "circle"
        case .running: return "play.circle.fill"
        case .reachedGoal: return "checkmark.circle.fill"
        case .maxTicks: return "stop.circle.fill"
        }
    }

    var statusColor: Color {
        switch status {
        case .idle: return .secondary
        case .running: return .blue
        case .reachedGoal: return .green
        case .maxTicks: return .orange
        }
    }

    // MARK: - Run control

    func toggleRun() { isRunning ? stop() : start() }

    func start() {
        guard !isFinished else { return }
        isRunning = true
        scheduleTimer()
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        stop()
        world = initialWorld
        tick = 0
        status = .idle
        trail = []
        log = []
        rng = SeededGenerator(seed: UInt64(max(seed, 0)))
        appendLog("Скидання. Seed = \(seed).")
    }

    private func scheduleTimer() {
        timer?.invalidate()
        let interval = 1.0 / max(ticksPerSecond, 0.5)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.step() }
        }
    }

    // MARK: - Tick

    /// Advance the simulation by one tick (PHYSICS.md §2, §5).
    func step() {
        guard !isFinished else { stop(); return }
        guard let agentIndex = world.entities.firstIndex(where: { $0.kind == .agent }),
              let goal = world.goal else { return }

        // 1. read current state
        var agent = world.entities[agentIndex]
        let from = agent.position

        // 2. apply update rules
        let moveProb = agent.props["move_prob"] ?? 0.85
        let next = decideMove(for: agent, goal: goal.position, moveProb: moveProb)

        // 3. write state for t+1
        agent.position = next
        world.entities[agentIndex] = agent
        tick += 1
        if from != next { trail.append(from) }
        status = .running

        evaluateStopConditions(agentPosition: next, goalPosition: goal.position)
    }

    /// Greedy step toward the goal with seed-controlled stochastic exploration.
    private func decideMove(for agent: Entity, goal: GridPosition, moveProb: Double) -> GridPosition {
        let pos = agent.position
        let dx = goal.x - pos.x
        let dy = goal.y - pos.y

        var greedy = pos
        if abs(dx) >= abs(dy), dx != 0 {
            greedy.x += dx > 0 ? 1 : -1
        } else if dy != 0 {
            greedy.y += dy > 0 ? 1 : -1
        } else if dx != 0 {
            greedy.x += dx > 0 ? 1 : -1
        }

        // PHYSICS.md §5: stochastic rule with a fixed seed.
        let roll = Double.random(in: 0..<1, using: &rng)
        if roll <= moveProb {
            return world.clamp(greedy)
        }
        let neighbours = world.neighbours(of: pos)
        return neighbours.randomElement(using: &rng) ?? world.clamp(greedy)
    }

    private func evaluateStopConditions(agentPosition: GridPosition, goalPosition: GridPosition) {
        if agentPosition == goalPosition {
            status = .reachedGoal
            stop()
            appendLog("✅ Ціль досягнута за \(tick) тіків.")
        } else if tick >= world.rules.maxTicks {
            status = .maxTicks
            stop()
            appendLog("⏹ Ліміт \(world.rules.maxTicks) тіків. Відстань до цілі: \(distanceToGoal).")
        }
    }

    private func appendLog(_ message: String) {
        log.append(LogEntry(tick: tick, message: message))
    }
}
