import Foundation
import GRDB

public enum AppDatabase {
    public static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            try db.create(table: "board") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("createdAt", .datetime).notNull()
            }

            try db.create(table: "boardColumn") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("boardId", .integer).notNull()
                    .references("board", onDelete: .cascade)
                t.column("name", .text).notNull()
                t.column("position", .integer).notNull()
            }

            try db.create(table: "story") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("boardColumnId", .integer).notNull()
                    .references("boardColumn", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("description", .text)
                t.column("position", .integer).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
        }

        migrator.registerMigration("v2") { db in
            try db.create(table: "sprint") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("boardId", .integer).notNull()
                    .references("board", onDelete: .cascade)
                t.column("name", .text).notNull()
                t.column("goal", .text)
                t.column("startDate", .datetime)
                t.column("endDate", .datetime)
                t.column("isActive", .boolean).notNull().defaults(to: false)
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }

            try db.alter(table: "story") { t in
                t.add(column: "sprintId", .integer)
                    .references("sprint", onDelete: .setNull)
            }
        }

        return migrator
    }

    public static func makeDatabasePool(at path: String) throws -> DatabasePool {
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }
        let pool = try DatabasePool(path: path, configuration: config)
        try migrator.migrate(pool)
        return pool
    }

    public static func makeDatabaseQueue(at path: String) throws -> DatabaseQueue {
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }
        let queue = try DatabaseQueue(path: path, configuration: config)
        try migrator.migrate(queue)
        return queue
    }
}
