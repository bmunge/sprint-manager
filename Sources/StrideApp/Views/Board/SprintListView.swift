import SwiftUI
import SprintManagerKit

struct SprintListView: View {
    let sprints: [Sprint]
    let onStart: (Sprint) -> Void
    let onComplete: (Sprint) -> Void
    let onDelete: (Sprint) -> Void

    var body: some View {
        List {
            ForEach(sprints) { sprint in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(sprint.name).font(.headline)
                            if sprint.isActive {
                                Text("Active")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.green.opacity(0.2))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                            }
                        }
                        if let goal = sprint.goal, !goal.isEmpty {
                            Text(goal)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .contextMenu {
                    if !sprint.isActive {
                        Button("Start Sprint") { onStart(sprint) }
                    }
                    if sprint.isActive {
                        Button("Complete Sprint") { onComplete(sprint) }
                    }
                    Divider()
                    Button("Delete", role: .destructive) { onDelete(sprint) }
                }
            }
        }
    }
}
