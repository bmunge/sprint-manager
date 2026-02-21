import MCP
import GRDB
import SprintManagerKit
import Foundation

enum BoardTools {
    static func listBoards(db: DatabaseQueue) throws -> CallTool.Result {
        let boards = try db.read { db in
            try BoardQueries.fetchAll(db: db)
        }
        let json = try jsonEncoder().encode(boards)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func createBoard(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let name = arguments?["name"]?.stringValue else {
            return .init(content: [.text("Missing required parameter: name")], isError: true)
        }
        let board = try db.write { db in
            try BoardQueries.create(db: db, name: name)
        }
        let json = try jsonEncoder().encode(board)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func deleteBoard(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let boardId = arguments?["boardId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: boardId")], isError: true)
        }
        let deleted = try db.write { db in
            try BoardQueries.delete(db: db, id: boardId)
        }
        if deleted {
            return .init(content: [.text("Board \(boardId) deleted successfully")])
        } else {
            return .init(content: [.text("Board \(boardId) not found")], isError: true)
        }
    }
}
