import SwiftUI
import GRDB
import SprintManagerKit
import CoreTransferable

extension Int64: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

struct ColumnView: View {
    let column: BoardColumn
    let viewMode: BoardViewMode
    let sprints: [Sprint]
    @State private var stories: [Story] = []
    @Environment(\.database) private var database
    @State private var isTargeted = false
    @State private var showingNewStorySheet = false

    private var selectedSprintId: Int64? {
        if case .sprint(let id) = viewMode { return id }
        return nil
    }

    private var isBacklog: Bool {
        if case .backlog = viewMode { return true }
        return false
    }

    /// Sprints available for assignment (planned + active)
    private var assignableSprints: [Sprint] {
        sprints.filter { $0.isActive || $0.endDate == nil }
    }

    /// Whether this is a completed sprint (read-only)
    private var isReadOnly: Bool {
        if let sprint = sprints.first(where: { $0.id == selectedSprintId }) {
            return !sprint.isActive && sprint.endDate != nil
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Colored accent bar at top
            RoundedRectangle(cornerRadius: 2)
                .fill(StrideTheme.columnAccent(for: column.name))
                .frame(height: StrideTheme.Column.headerHeight)
                .padding(.horizontal, 8)

            HStack {
                Text(column.name)
                    .font(.headline)
                Spacer()
                Text("\(stories.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(stories) { story in
                        StoryCardView(story: story, accentColor: StrideTheme.columnAccent(for: column.name))
                            .draggable(story.id ?? 0)
                            .contextMenu {
                                if isBacklog {
                                    // From backlog, assign to any sprint
                                    if !assignableSprints.isEmpty {
                                        Menu("Assign to Sprint") {
                                            ForEach(assignableSprints) { sprint in
                                                Button {
                                                    assignToSprint(story: story, sprintId: sprint.id)
                                                } label: {
                                                    Label(
                                                        sprint.name,
                                                        systemImage: sprint.isActive ? "circle.fill" : "circle.dashed"
                                                    )
                                                }
                                            }
                                        }
                                    }
                                } else if story.sprintId != nil {
                                    Button("Remove from Sprint") {
                                        assignToSprint(story: story, sprintId: nil)
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isReadOnly {
                Button(action: { showingNewStorySheet = true }) {
                    Label("Add Story", systemImage: "plus")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: StrideTheme.Column.cornerRadius)
                .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color(.controlBackgroundColor))
        )
        .dropDestination(for: Int64.self) { droppedIds, _ in
            guard !isReadOnly,
                  let storyId = droppedIds.first,
                  let columnId = column.id else { return false }
            moveStory(storyId: storyId, toColumn: columnId)
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .sheet(isPresented: $showingNewStorySheet) {
            if let columnId = column.id {
                NewStorySheet(columnId: columnId, sprintId: selectedSprintId)
            }
        }
        .task(id: viewMode) {
            await observeStories()
        }
        .task(id: column.id) {
            await observeStories()
        }
    }

    private func observeStories() async {
        guard let db = database, let columnId = column.id else { return }
        let sid = selectedSprintId
        let backlog = isBacklog
        let observation = ValueObservation.tracking { db in
            let all = try StoryQueries.fetchForColumn(db: db, columnId: columnId)
            if backlog {
                return all.filter { $0.sprintId == nil }
            } else if let sid {
                return all.filter { $0.sprintId == sid }
            } else {
                return all
            }
        }
        do {
            for try await stories in observation.values(in: db) {
                self.stories = stories
            }
        } catch {}
    }

    private func moveStory(storyId: Int64, toColumn columnId: Int64) {
        guard let db = database else { return }
        try? db.write { db in
            _ = try StoryQueries.move(db: db, storyId: storyId, targetColumnId: columnId, position: stories.count)
        }
    }

    private func assignToSprint(story: Story, sprintId: Int64?) {
        guard let storyId = story.id, let db = database else { return }
        try? db.write { db in
            _ = try StoryQueries.assignToSprint(db: db, storyId: storyId, sprintId: sprintId)
        }
    }
}
