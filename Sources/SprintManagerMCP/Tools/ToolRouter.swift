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

func handleToolCall(params: CallTool.Parameters, db: DatabaseQueue) throws -> CallTool.Result {
    switch params.name {
    case "list_boards":
        return try BoardTools.listBoards(db: db)
    case "create_board":
        return try BoardTools.createBoard(arguments: params.arguments, db: db)
    case "delete_board":
        return try BoardTools.deleteBoard(arguments: params.arguments, db: db)
    case "list_columns":
        return try ColumnTools.listColumns(arguments: params.arguments, db: db)
    case "create_column":
        return try ColumnTools.createColumn(arguments: params.arguments, db: db)
    case "list_stories":
        return try StoryTools.listStories(arguments: params.arguments, db: db)
    case "create_story":
        return try StoryTools.createStory(arguments: params.arguments, db: db)
    case "update_story":
        return try StoryTools.updateStory(arguments: params.arguments, db: db)
    case "move_story":
        return try StoryTools.moveStory(arguments: params.arguments, db: db)
    case "delete_story":
        return try StoryTools.deleteStory(arguments: params.arguments, db: db)
    default:
        return .init(content: [.text("Unknown tool: \(params.name)")], isError: true)
    }
}
