import SwiftUI
import SprintManagerKit

struct NewSprintSheet: View {
    let boardId: Int64
    @Environment(\.dismiss) var dismiss
    @Environment(\.database) private var database
    @State private var name = ""
    @State private var goal = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Sprint").font(.headline)

            TextField("Sprint Name", text: $name)
                .textFieldStyle(.roundedBorder)

            Text("Goal (optional)").font(.subheadline)
            TextField("What do you want to achieve?", text: $goal)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Create") { createSprint() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 360)
    }

    private func createSprint() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, let db = database else { return }
        let trimmedGoal = goal.trimmingCharacters(in: .whitespaces)
        try? db.write { db in
            _ = try SprintQueries.create(
                db: db,
                boardId: boardId,
                name: trimmedName,
                goal: trimmedGoal.isEmpty ? nil : trimmedGoal
            )
        }
        dismiss()
    }
}
