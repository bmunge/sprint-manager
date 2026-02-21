import SwiftUI
import SprintManagerKit

struct NewBoardSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.database) private var database
    @State private var boardName = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("New Board").font(.headline)
            TextField("Board name", text: $boardName)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Create") { createBoard() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(boardName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }

    private func createBoard() {
        let trimmed = boardName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let db = database else { return }
        try? db.write { db in
            _ = try BoardQueries.create(db: db, name: trimmed)
        }
        dismiss()
    }
}
