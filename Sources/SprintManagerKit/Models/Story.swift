import Foundation
import GRDB

public struct Story: Codable, Identifiable, Equatable {
    public var id: Int64?
    public var boardColumnId: Int64
    public var title: String
    public var description: String?
    public var position: Int
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: Int64? = nil,
        boardColumnId: Int64,
        title: String,
        description: String? = nil,
        position: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.boardColumnId = boardColumnId
        self.title = title
        self.description = description
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Story: FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "story"

    public static let boardColumn = belongsTo(BoardColumn.self)

    public enum Columns {
        static let id = Column(CodingKeys.id)
        static let boardColumnId = Column(CodingKeys.boardColumnId)
        static let title = Column(CodingKeys.title)
        static let description = Column(CodingKeys.description)
        static let position = Column(CodingKeys.position)
        static let createdAt = Column(CodingKeys.createdAt)
        static let updatedAt = Column(CodingKeys.updatedAt)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
