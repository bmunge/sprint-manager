import Foundation
import GRDB

public struct Board: Codable, Identifiable, Equatable {
    public var id: Int64?
    public var name: String
    public var createdAt: Date

    public init(id: Int64? = nil, name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

extension Board: FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "board"

    public static let columns = hasMany(BoardColumn.self)

    public enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let createdAt = Column(CodingKeys.createdAt)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
