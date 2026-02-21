import Foundation
import GRDB

public enum SprintQueries {
    public static func fetchForBoard(db: Database, boardId: Int64) throws -> [Sprint] {
        try Sprint
            .filter(Sprint.Columns.boardId == boardId)
            .order(Sprint.Columns.createdAt.desc)
            .fetchAll(db)
    }

    public static func fetchActive(db: Database, boardId: Int64) throws -> Sprint? {
        try Sprint
            .filter(Sprint.Columns.boardId == boardId)
            .filter(Sprint.Columns.isActive == true)
            .fetchOne(db)
    }

    public static func create(
        db: Database,
        boardId: Int64,
        name: String,
        goal: String? = nil
    ) throws -> Sprint {
        var sprint = Sprint(boardId: boardId, name: name, goal: goal)
        try sprint.insert(db)
        return sprint
    }

    public static func start(db: Database, sprintId: Int64) throws -> Sprint {
        guard var sprint = try Sprint.fetchOne(db, key: sprintId) else {
            throw DatabaseError(message: "Sprint not found: \(sprintId)")
        }

        // Deactivate any other active sprint on the same board
        try Sprint
            .filter(Sprint.Columns.boardId == sprint.boardId)
            .filter(Sprint.Columns.isActive == true)
            .updateAll(db, Sprint.Columns.isActive.set(to: false))

        sprint.isActive = true
        sprint.startDate = Date()
        try sprint.update(db)
        return sprint
    }

    public static func complete(db: Database, sprintId: Int64) throws -> Sprint {
        guard var sprint = try Sprint.fetchOne(db, key: sprintId) else {
            throw DatabaseError(message: "Sprint not found: \(sprintId)")
        }

        sprint.isActive = false
        sprint.endDate = Date()
        try sprint.update(db)

        // Find the last column for this board (the "Done" column)
        let lastColumn = try BoardColumn
            .filter(BoardColumn.Columns.boardId == sprint.boardId)
            .order(BoardColumn.Columns.position.desc)
            .fetchOne(db)

        // Move incomplete stories (not in last column) back to backlog
        if let lastColumnId = lastColumn?.id {
            try Story
                .filter(Story.Columns.sprintId == sprintId)
                .filter(Story.Columns.boardColumnId != lastColumnId)
                .updateAll(db, Story.Columns.sprintId.set(to: nil))
        }

        return sprint
    }

    public static func delete(db: Database, id: Int64) throws -> Bool {
        try Sprint.deleteOne(db, key: id)
    }
}
