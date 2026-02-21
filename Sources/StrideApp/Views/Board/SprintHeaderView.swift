import SwiftUI
import SprintManagerKit

enum BoardViewMode: Hashable {
    case sprint(Int64) // viewing a specific sprint
    case backlog
}

struct SprintHeaderView: View {
    let sprints: [Sprint]
    @Binding var viewMode: BoardViewMode
    let onStartSprint: (Sprint) -> Void
    let onEndSprint: (Sprint) -> Void
    let onDeleteSprint: (Sprint) -> Void
    let onNewSprint: () -> Void

    private var selectedSprint: Sprint? {
        if case .sprint(let id) = viewMode {
            return sprints.first { $0.id == id }
        }
        return nil
    }

    private var plannedSprints: [Sprint] {
        sprints.filter { !$0.isActive && $0.endDate == nil }
    }

    private var activeSprints: [Sprint] {
        sprints.filter { $0.isActive }
    }

    private var completedSprints: [Sprint] {
        sprints.filter { !$0.isActive && $0.endDate != nil }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Sprint picker
            Menu {
                Section("Active") {
                    ForEach(activeSprints) { sprint in
                        sprintButton(sprint, badge: "circle.fill")
                    }
                }

                if !plannedSprints.isEmpty {
                    Section("Planned") {
                        ForEach(plannedSprints) { sprint in
                            sprintButton(sprint, badge: "circle.dashed")
                        }
                    }
                }

                if !completedSprints.isEmpty {
                    Section("Completed") {
                        ForEach(completedSprints) { sprint in
                            sprintButton(sprint, badge: "checkmark.circle")
                        }
                    }
                }

                Divider()

                Button {
                    viewMode = .backlog
                } label: {
                    Label("Backlog", systemImage: "tray")
                }

                Divider()

                Button("New Sprint...", systemImage: "plus") {
                    onNewSprint()
                }
            } label: {
                HStack(spacing: 6) {
                    if let sprint = selectedSprint {
                        statusDot(for: sprint)
                        Text(sprint.name)
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: "tray")
                        Text("Backlog")
                            .fontWeight(.semibold)
                    }
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .font(.title3)
            }
            .buttonStyle(.plain)

            // Sprint goal
            if let sprint = selectedSprint, let goal = sprint.goal, !goal.isEmpty {
                Text("—")
                    .foregroundStyle(.quaternary)
                Text(goal)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Contextual actions
            if let sprint = selectedSprint {
                sprintActions(for: sprint)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func sprintButton(_ sprint: Sprint, badge: String) -> some View {
        Button {
            if let id = sprint.id {
                viewMode = .sprint(id)
            }
        } label: {
            Label(sprint.name, systemImage: badge)
        }
    }

    @ViewBuilder
    private func statusDot(for sprint: Sprint) -> some View {
        Circle()
            .fill(statusColor(for: sprint))
            .frame(width: 8, height: 8)
    }

    private func statusColor(for sprint: Sprint) -> Color {
        if sprint.isActive { return .green }
        if sprint.endDate != nil { return .secondary }
        return .orange
    }

    @ViewBuilder
    private func sprintActions(for sprint: Sprint) -> some View {
        if sprint.isActive {
            Button("End Sprint") { onEndSprint(sprint) }
                .buttonStyle(.bordered)
        } else if sprint.endDate == nil {
            // Planned sprint
            HStack(spacing: 8) {
                Button("Start Sprint") { onStartSprint(sprint) }
                    .buttonStyle(.borderedProminent)
                Button(role: .destructive) {
                    onDeleteSprint(sprint)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
            }
        } else {
            // Completed — read-only indicator
            Text("Completed")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.secondary.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}
