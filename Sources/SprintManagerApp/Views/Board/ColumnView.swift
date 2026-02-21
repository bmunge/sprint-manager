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
    @State private var stories: [Story] = []
    @Environment(\.database) private var database
    @State private var isTargeted = false
    @State private var showingNewStorySheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                        StoryCardView(story: story)
                            .draggable(story.id ?? 0)
                    }
                }
                .padding(.horizontal, 4)
            }

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
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color(.controlBackgroundColor))
        )
        .dropDestination(for: Int64.self) { droppedIds, _ in
            guard let storyId = droppedIds.first, let columnId = column.id else { return false }
            moveStory(storyId: storyId, toColumn: columnId)
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .sheet(isPresented: $showingNewStorySheet) {
            if let columnId = column.id {
                NewStorySheet(columnId: columnId)
            }
        }
        .task(id: column.id) {
            await observeStories()
        }
    }

    private func observeStories() async {
        guard let db = database, let columnId = column.id else { return }
        let observation = ValueObservation.tracking { db in
            try StoryQueries.fetchForColumn(db: db, columnId: columnId)
        }
        do {
            for try await stories in observation.values(in: db) {
                self.stories = stories
            }
        } catch {
            // Observation cancelled
        }
    }

    private func moveStory(storyId: Int64, toColumn columnId: Int64) {
        guard let db = database else { return }
        try? db.write { db in
            _ = try StoryQueries.move(db: db, storyId: storyId, targetColumnId: columnId, position: stories.count)
        }
    }
}
