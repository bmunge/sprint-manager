import SwiftUI
import SprintManagerKit

struct NewStorySheet: View {
    let columnId: Int64
    let sprintId: Int64?
    @Environment(\.dismiss) var dismiss
    @Environment(\.database) private var database
    @State private var storyTitle = ""
    @State private var storyDescription = ""

    init(columnId: Int64, sprintId: Int64? = nil) {
        self.columnId = columnId
        self.sprintId = sprintId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Story").font(.headline)

            TextField("Title", text: $storyTitle)
                .textFieldStyle(.roundedBorder)

            Text("Description").font(.subheadline)
            TextEditor(text: $storyDescription)
                .frame(minHeight: 80)
                .border(Color(.separatorColor))

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Create") { createStory() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(storyTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 360)
    }

    private func createStory() {
        let trimmedTitle = storyTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty, let db = database else { return }
        let trimmedDescription = storyDescription.trimmingCharacters(in: .whitespaces)
        try? db.write { db in
            _ = try StoryQueries.create(
                db: db,
                columnId: columnId,
                title: trimmedTitle,
                description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                sprintId: sprintId
            )
        }
        dismiss()
    }
}
