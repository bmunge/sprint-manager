import Foundation
import GRDB

public enum BoardQueries {
    public static func fetchAll(db: Database) throws -> [Board] {
        try Board.order(Board.Columns.createdAt).fetchAll(db)
    }

    public static func create(db: Database, name: String) throws -> Board {
        var board = Board(name: name)
        try board.insert(db)

        let boardId = board.id!
        let defaultColumns = ["To Do", "In Progress", "In Review", "Done"]
        for (index, columnName) in defaultColumns.enumerated() {
            var column = BoardColumn(boardId: boardId, name: columnName, position: index)
            try column.insert(db)
        }

        return board
    }

    public static func delete(db: Database, id: Int64) throws -> Bool {
        try Board.deleteOne(db, key: id)
    }
}
