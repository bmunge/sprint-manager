import SwiftUI

struct ContentView: View {
    @State private var selectedBoardId: Int64?

    var body: some View {
        NavigationSplitView {
            BoardListView(selectedBoardId: $selectedBoardId)
        } detail: {
            if let boardId = selectedBoardId {
                BoardView(boardId: boardId)
            } else {
                Text("Select a board")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
