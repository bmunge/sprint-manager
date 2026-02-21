import Foundation
import GRDB

public struct BoardColumn: Codable, Identifiable, Equatable {
    public var id: Int64?
    public var boardId: Int64
    public var name: String
    public var position: Int

    public init(id: Int64? = nil, boardId: Int64, name: String, position: Int) {
        self.id = id
        self.boardId = boardId
        self.name = name
        self.position = position
    }
}

extension BoardColumn: FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "boardColumn"

    public static let board = belongsTo(Board.self)
    public static let stories = hasMany(Story.self)

    public enum Columns {
        static let id = Column(CodingKeys.id)
        static let boardId = Column(CodingKeys.boardId)
        static let name = Column(CodingKeys.name)
        static let position = Column(CodingKeys.position)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
