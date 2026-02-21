import SwiftUI
import GRDB
import SprintManagerKit

struct BoardListView: View {
    @Binding var selectedBoardId: Int64?
    @State private var boards: [Board] = []
    @State private var showingNewBoardSheet = false
    @Environment(\.database) private var database

    var body: some View {
        List(boards, selection: $selectedBoardId) { board in
            Text(board.name)
                .tag(board.id)
                .contextMenu {
                    Button("Delete", role: .destructive) { deleteBoard(board) }
                }
        }
        .navigationTitle("Boards")
        .toolbar {
            Button(action: { showingNewBoardSheet = true }) {
                Label("New Board", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingNewBoardSheet) {
            NewBoardSheet()
        }
        .task {
            await observeBoards()
        }
    }

    private func observeBoards() async {
        guard let db = database else { return }
        let observation = ValueObservation.tracking { db in
            try BoardQueries.fetchAll(db: db)
        }
        do {
            for try await boards in observation.values(in: db) {
                self.boards = boards
            }
        } catch {
            // Observation cancelled
        }
    }

    private func deleteBoard(_ board: Board) {
        guard let id = board.id, let db = database else { return }
        try? db.write { db in
            _ = try BoardQueries.delete(db: db, id: id)
        }
        if selectedBoardId == id { selectedBoardId = nil }
    }
}
