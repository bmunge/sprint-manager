import MCP
import GRDB
import SprintManagerKit
import Foundation

enum ColumnTools {
    static func listColumns(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let boardId = arguments?["boardId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: boardId")], isError: true)
        }
        let columns = try db.read { db in
            try ColumnQueries.fetchForBoard(db: db, boardId: boardId)
        }
        let json = try jsonEncoder().encode(columns)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func createColumn(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let boardId = arguments?["boardId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: boardId")], isError: true)
        }
        guard let name = arguments?["name"]?.stringValue else {
            return .init(content: [.text("Missing required parameter: name")], isError: true)
        }
        let column = try db.write { db in
            try ColumnQueries.create(db: db, boardId: boardId, name: name)
        }
        let json = try jsonEncoder().encode(column)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }
}
