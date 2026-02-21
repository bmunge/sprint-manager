import SwiftUI

enum StrideTheme {
    // Column accent colors by name
    static func columnAccent(for name: String) -> Color {
        switch name.lowercased() {
        case "to do": return .orange
        case "in progress": return .blue
        case "in review": return .purple
        case "done": return .green
        default: return .gray
        }
    }

    // Card styling
    enum Card {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 10
        static let shadowRadius: CGFloat = 2
        static let shadowY: CGFloat = 1
        static let shadowOpacity: Double = 0.12
        static let hoverHighlight: Double = 0.04
    }

    // Column styling
    enum Column {
        static let cornerRadius: CGFloat = 10
        static let headerHeight: CGFloat = 4
        static let width: CGFloat = 280
        static let spacing: CGFloat = 16
    }

    // Sprint header
    enum SprintHeader {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
    }
}
