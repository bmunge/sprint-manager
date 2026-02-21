import SwiftUI
import SprintManagerKit

struct StoryCardView: View {
    let story: Story
    var accentColor: Color = .blue
    @State private var showingDetail = false
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4)

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
            .padding(StrideTheme.Card.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: StrideTheme.Card.cornerRadius)
                .fill(Color(.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: StrideTheme.Card.cornerRadius)
                .fill(Color.primary.opacity(isHovered ? StrideTheme.Card.hoverHighlight : 0))
        )
        .clipShape(RoundedRectangle(cornerRadius: StrideTheme.Card.cornerRadius))
        .shadow(
            color: .black.opacity(StrideTheme.Card.shadowOpacity),
            radius: StrideTheme.Card.shadowRadius,
            y: StrideTheme.Card.shadowY
        )
        .onHover { isHovered = $0 }
        .onTapGesture { showingDetail = true }
        .sheet(isPresented: $showingDetail) {
            StoryDetailView(story: story)
        }
    }
}
