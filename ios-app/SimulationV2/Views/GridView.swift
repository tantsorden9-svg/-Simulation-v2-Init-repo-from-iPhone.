import SwiftUI

/// Renders the discrete grid world: cells, the agent's trail, the goal and the agent.
struct GridView: View {
    @ObservedObject var engine: SimulationEngine

    var body: some View {
        Canvas { context, size in
            let world = engine.world
            let columns = world.width
            let rows = world.height
            let cell = min(size.width / CGFloat(columns), size.height / CGFloat(rows))
            let originX = (size.width - cell * CGFloat(columns)) / 2
            let originY = (size.height - cell * CGFloat(rows)) / 2

            func rect(_ p: GridPosition) -> CGRect {
                CGRect(x: originX + CGFloat(p.x) * cell,
                       y: originY + CGFloat(p.y) * cell,
                       width: cell, height: cell)
            }

            // Empty cells.
            for y in 0..<rows {
                for x in 0..<columns {
                    let r = rect(GridPosition(x: x, y: y)).insetBy(dx: 1, dy: 1)
                    context.fill(Path(roundedRect: r, cornerRadius: 3),
                                 with: .color(Color(.secondarySystemBackground)))
                }
            }

            // Agent trail.
            for p in engine.trail {
                let r = rect(p).insetBy(dx: cell * 0.3, dy: cell * 0.3)
                context.fill(Path(ellipseIn: r), with: .color(.blue.opacity(0.25)))
            }

            // Goal.
            if let goal = engine.world.goal {
                let r = rect(goal.position).insetBy(dx: 3, dy: 3)
                context.fill(Path(roundedRect: r, cornerRadius: 5), with: .color(.green))
                let star = rect(goal.position).insetBy(dx: cell * 0.28, dy: cell * 0.28)
                context.draw(Text(Image(systemName: "flag.fill")).foregroundColor(.white),
                             in: star)
            }

            // Agent.
            if let agent = engine.world.agent {
                let r = rect(agent.position).insetBy(dx: cell * 0.18, dy: cell * 0.18)
                context.fill(Path(ellipseIn: r), with: .color(.orange))
                context.stroke(Path(ellipseIn: r), with: .color(.white), lineWidth: 2)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: engine.tick)
    }
}
