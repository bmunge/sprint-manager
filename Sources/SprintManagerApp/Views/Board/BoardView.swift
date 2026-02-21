import SwiftUI
import GRDB
import SprintManagerKit

struct BoardView: View {
    let boardId: Int64
    @State private var columns: [BoardColumn] = []
    @Environment(\.database) private var database

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(columns) { column in
                    ColumnView(column: column)
                        .frame(width: 280)
                }
            }
            .padding()
        }
        .task(id: boardId) {
            await observeColumns()
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
        } catch {
            // Observation cancelled
        }
    }
}
