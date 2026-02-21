import MCP
import GRDB
import SprintManagerKit
import Foundation

enum StoryTools {
    static func listStories(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        let boardId = arguments?["boardId"]?.int64Value
        let columnId = arguments?["columnId"]?.int64Value

        guard boardId != nil || columnId != nil else {
            return .init(
                content: [.text("At least one of boardId or columnId is required")],
                isError: true
            )
        }

        let stories: [Story]
        if let columnId {
            stories = try db.read { db in
                try StoryQueries.fetchForColumn(db: db, columnId: columnId)
            }
        } else {
            stories = try db.read { db in
                try StoryQueries.fetchForBoard(db: db, boardId: boardId!)
            }
        }

        let json = try jsonEncoder().encode(stories)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func createStory(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let columnId = arguments?["columnId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: columnId")], isError: true)
        }
        guard let title = arguments?["title"]?.stringValue else {
            return .init(content: [.text("Missing required parameter: title")], isError: true)
        }
        let description = arguments?["description"]?.stringValue

        let story = try db.write { db in
            try StoryQueries.create(db: db, columnId: columnId, title: title, description: description)
        }
        let json = try jsonEncoder().encode(story)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func updateStory(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let storyId = arguments?["storyId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: storyId")], isError: true)
        }
        let title = arguments?["title"]?.stringValue
        let description = arguments?["description"]?.stringValue

        let story = try db.write { db in
            try StoryQueries.update(db: db, storyId: storyId, title: title, description: description)
        }
        let json = try jsonEncoder().encode(story)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func moveStory(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let storyId = arguments?["storyId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: storyId")], isError: true)
        }
        guard let targetColumnId = arguments?["targetColumnId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: targetColumnId")], isError: true)
        }
        guard let position = arguments?["position"]?.integerValue else {
            return .init(content: [.text("Missing required parameter: position")], isError: true)
        }

        let story = try db.write { db in
            try StoryQueries.move(db: db, storyId: storyId, targetColumnId: targetColumnId, position: position)
        }
        let json = try jsonEncoder().encode(story)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func deleteStory(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let storyId = arguments?["storyId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: storyId")], isError: true)
        }
        let deleted = try db.write { db in
            try StoryQueries.delete(db: db, id: storyId)
        }
        if deleted {
            return .init(content: [.text("Story \(storyId) deleted successfully")])
        } else {
            return .init(content: [.text("Story \(storyId) not found")], isError: true)
        }
    }
}
