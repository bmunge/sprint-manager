import SwiftUI
import SprintManagerKit

struct StoryDetailView: View {
    let story: Story
    @Environment(\.dismiss) var dismiss
    @Environment(\.database) private var database
    @State private var title: String
    @State private var description: String
    @State private var showingDeleteAlert = false

    init(story: Story) {
        self.story = story
        _title = State(initialValue: story.title)
        _description = State(initialValue: story.description ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Story").font(.headline)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)

            Text("Description").font(.subheadline)
            TextEditor(text: $description)
                .frame(minHeight: 100)
                .border(Color(.separatorColor))

            HStack {
                Button("Delete", role: .destructive) { showingDeleteAlert = true }
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") { saveStory() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .alert("Delete Story", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteStory() }
        } message: {
            Text("Are you sure you want to delete \"\(story.title)\"? This cannot be undone.")
        }
    }

    private func saveStory() {
        guard let id = story.id, let db = database else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        try? db.write { db in
            _ = try StoryQueries.update(
                db: db,
                storyId: id,
                title: trimmedTitle,
                description: trimmedDescription.isEmpty ? nil : trimmedDescription
            )
        }
        dismiss()
    }

    private func deleteStory() {
        guard let id = story.id, let db = database else { return }
        try? db.write { db in
            _ = try StoryQueries.delete(db: db, id: id)
        }
        dismiss()
    }
}
