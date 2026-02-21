import MCP
import GRDB
import SprintManagerKit
import Foundation

extension Value {
    var int64Value: Int64? {
        if case .int(let i) = self { return Int64(i) }
        if case .double(let d) = self { return Int64(exactly: d) }
        return nil
    }

    var integerValue: Int? {
        if case .int(let i) = self { return i }
        if case .double(let d) = self { return Int(exactly: d) }
        return nil
    }
}

func jsonEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}

/// Tools that mutate the database — post a Darwin notification so the app refreshes.
private let writingTools: Set<String> = [
    "create_board", "delete_board", "create_column",
    "create_story", "update_story", "move_story", "delete_story",
]

func handleToolCall(params: CallTool.Parameters, db: DatabaseQueue) throws -> CallTool.Result {
    let result: CallTool.Result
    switch params.name {
    case "list_boards":
        result = try BoardTools.listBoards(db: db)
    case "create_board":
        result = try BoardTools.createBoard(arguments: params.arguments, db: db)
    case "delete_board":
        result = try BoardTools.deleteBoard(arguments: params.arguments, db: db)
    case "list_columns":
        result = try ColumnTools.listColumns(arguments: params.arguments, db: db)
    case "create_column":
        result = try ColumnTools.createColumn(arguments: params.arguments, db: db)
    case "list_stories":
        result = try StoryTools.listStories(arguments: params.arguments, db: db)
    case "create_story":
        result = try StoryTools.createStory(arguments: params.arguments, db: db)
    case "update_story":
        result = try StoryTools.updateStory(arguments: params.arguments, db: db)
    case "move_story":
        result = try StoryTools.moveStory(arguments: params.arguments, db: db)
    case "delete_story":
        result = try StoryTools.deleteStory(arguments: params.arguments, db: db)
    default:
        return .init(content: [.text("Unknown tool: \(params.name)")], isError: true)
    }

    if writingTools.contains(params.name) && result.isError != true {
        CrossProcessNotifier.postDidChange()
    }

    return result
}
