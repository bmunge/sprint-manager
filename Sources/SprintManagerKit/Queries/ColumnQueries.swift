import Foundation
import GRDB

public enum ColumnQueries {
    public static func fetchForBoard(db: Database, boardId: Int64) throws -> [BoardColumn] {
        try BoardColumn
            .filter(BoardColumn.Columns.boardId == boardId)
            .order(BoardColumn.Columns.position)
            .fetchAll(db)
    }

    public static func create(db: Database, boardId: Int64, name: String) throws -> BoardColumn {
        let maxPosition = try BoardColumn
            .filter(BoardColumn.Columns.boardId == boardId)
            .select(max(BoardColumn.Columns.position))
            .fetchOne(db) as Int? ?? -1

        var column = BoardColumn(boardId: boardId, name: name, position: maxPosition + 1)
        try column.insert(db)
        return column
    }
}
