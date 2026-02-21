import SwiftUI
import GRDB
import SprintManagerKit

struct BoardView: View {
    let boardId: Int64
    @State private var columns: [BoardColumn] = []
    @State private var sprints: [Sprint] = []
    @State private var viewMode: BoardViewMode = .backlog
    @State private var showingNewSprintSheet = false
    @Environment(\.database) private var database

    var body: some View {
        VStack(spacing: 0) {
            SprintHeaderView(
                sprints: sprints,
                viewMode: $viewMode,
                onStartSprint: startSprint,
                onEndSprint: endSprint,
                onDeleteSprint: deleteSprint,
                onNewSprint: { showingNewSprintSheet = true }
            )

            Divider()

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: StrideTheme.Column.spacing) {
                    ForEach(columns) { column in
                        ColumnView(
                            column: column,
                            viewMode: viewMode,
                            sprints: sprints
                        )
                        .frame(width: StrideTheme.Column.width)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingNewSprintSheet) {
            NewSprintSheet(boardId: boardId)
        }
        .task(id: boardId) {
            await observeColumns()
        }
        .task(id: boardId) {
            await observeSprints()
        }
    }

    private func observeColumns() async {
        guard let db = database else { return }
        let bid = boardId
        let observation = ValueObservation.tracking { db in
            try ColumnQueries.fetchForBoard(db: db, boardId: bid)
        }
        do {
            for try await columns in observation.values(in: db) {
                self.columns = columns
            }
        } catch {}
    }

    private func observeSprints() async {
        guard let db = database else { return }
        let bid = boardId
        let observation = ValueObservation.tracking { db in
            try SprintQueries.fetchForBoard(db: db, boardId: bid)
        }
        do {
            for try await all in observation.values(in: db) {
                self.sprints = all
                // Auto-select active sprint if current selection is invalid
                switch viewMode {
                case .sprint(let id):
                    if !all.contains(where: { $0.id == id }) {
                        // Selected sprint was deleted — fall back
                        if let active = all.first(where: { $0.isActive }) {
                            viewMode = .sprint(active.id!)
                        } else {
                            viewMode = .backlog
                        }
                    }
                case .backlog:
                    // If an active sprint just appeared (e.g. first sprint started),
                    // auto-switch to it
                    if let active = all.first(where: { $0.isActive }),
                       sprints.first(where: { $0.isActive }) == nil {
                        viewMode = .sprint(active.id!)
                    }
                }
            }
        } catch {}
    }

    private func startSprint(_ sprint: Sprint) {
        guard let id = sprint.id, let db = database else { return }
        try? db.write { db in
            _ = try SprintQueries.start(db: db, sprintId: id)
        }
        viewMode = .sprint(id)
    }

    private func endSprint(_ sprint: Sprint) {
        guard let id = sprint.id, let db = database else { return }
        try? db.write { db in
            _ = try SprintQueries.complete(db: db, sprintId: id)
        }
    }

    private func deleteSprint(_ sprint: Sprint) {
        guard let id = sprint.id, let db = database else { return }
        try? db.write { db in
            _ = try SprintQueries.delete(db: db, id: id)
        }
        viewMode = .backlog
    }
}
