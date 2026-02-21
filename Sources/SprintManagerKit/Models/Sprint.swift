import Foundation
import GRDB

public struct Sprint: Codable, Identifiable, Equatable {
    public var id: Int64?
    public var boardId: Int64
    public var name: String
    public var goal: String?
    public var startDate: Date?
    public var endDate: Date?
    public var isActive: Bool
    public var createdAt: Date

    public init(
        id: Int64? = nil,
        boardId: Int64,
        name: String,
        goal: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        isActive: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.boardId = boardId
        self.name = name
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

extension Sprint: FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "sprint"

    public static let board = belongsTo(Board.self)
    public static let stories = hasMany(Story.self)

    public enum Columns {
        static let id = Column(CodingKeys.id)
        static let boardId = Column(CodingKeys.boardId)
        static let name = Column(CodingKeys.name)
        static let goal = Column(CodingKeys.goal)
        static let startDate = Column(CodingKeys.startDate)
        static let endDate = Column(CodingKeys.endDate)
        static let isActive = Column(CodingKeys.isActive)
        static let createdAt = Column(CodingKeys.createdAt)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
