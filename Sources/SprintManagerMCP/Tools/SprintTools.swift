import MCP
import GRDB
import SprintManagerKit
import Foundation

enum SprintTools {
    static func listSprints(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let boardId = arguments?["boardId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: boardId")], isError: true)
        }
        let sprints = try db.read { db in
            try SprintQueries.fetchForBoard(db: db, boardId: boardId)
        }
        let json = try jsonEncoder().encode(sprints)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func createSprint(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let boardId = arguments?["boardId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: boardId")], isError: true)
        }
        guard let name = arguments?["name"]?.stringValue else {
            return .init(content: [.text("Missing required parameter: name")], isError: true)
        }
        let goal = arguments?["goal"]?.stringValue

        let sprint = try db.write { db in
            try SprintQueries.create(db: db, boardId: boardId, name: name, goal: goal)
        }
        let json = try jsonEncoder().encode(sprint)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func startSprint(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let sprintId = arguments?["sprintId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: sprintId")], isError: true)
        }
        let sprint = try db.write { db in
            try SprintQueries.start(db: db, sprintId: sprintId)
        }
        let json = try jsonEncoder().encode(sprint)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }

    static func completeSprint(arguments: [String: Value]?, db: DatabaseQueue) throws -> CallTool.Result {
        guard let sprintId = arguments?["sprintId"]?.int64Value else {
            return .init(content: [.text("Missing required parameter: sprintId")], isError: true)
        }
        let sprint = try db.write { db in
            try SprintQueries.complete(db: db, sprintId: sprintId)
        }
        let json = try jsonEncoder().encode(sprint)
        return .init(content: [.text(String(data: json, encoding: .utf8)!)])
    }
}
