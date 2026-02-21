import SwiftUI
import SprintManagerKit

struct StoryCardView: View {
    let story: Story
    @State private var showingDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(story.title)
                .font(.subheadline)
                .fontWeight(.medium)
            if let description = story.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color(.windowBackgroundColor)))
        .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        .onTapGesture { showingDetail = true }
        .sheet(isPresented: $showingDetail) {
            StoryDetailView(story: story)
        }
    }
}
