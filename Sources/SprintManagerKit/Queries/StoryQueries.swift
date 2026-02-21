import Foundation
import GRDB

public enum StoryQueries {
    public static func fetchForColumn(db: Database, columnId: Int64) throws -> [Story] {
        try Story
            .filter(Story.Columns.boardColumnId == columnId)
            .order(Story.Columns.position)
            .fetchAll(db)
    }

    public static func fetchForBoard(db: Database, boardId: Int64) throws -> [Story] {
        let columns = try BoardColumn
            .filter(BoardColumn.Columns.boardId == boardId)
            .fetchAll(db)
        let columnIds = columns.compactMap { $0.id }
        return try Story
            .filter(columnIds.contains(Story.Columns.boardColumnId))
            .order(Story.Columns.boardColumnId, Story.Columns.position)
            .fetchAll(db)
    }

    public static func create(
        db: Database,
        columnId: Int64,
        title: String,
        description: String?
    ) throws -> Story {
        let maxPosition = try Story
            .filter(Story.Columns.boardColumnId == columnId)
            .select(max(Story.Columns.position))
            .fetchOne(db) as Int? ?? -1

        var story = Story(
            boardColumnId: columnId,
            title: title,
            description: description,
            position: maxPosition + 1
        )
        try story.insert(db)
        return story
    }

    public static func update(
        db: Database,
        storyId: Int64,
        title: String?,
        description: String?
    ) throws -> Story {
        guard var story = try Story.fetchOne(db, key: storyId) else {
            throw DatabaseError(message: "Story not found: \(storyId)")
        }
        if let title {
            story.title = title
        }
        if let description {
            story.description = description
        }
        story.updatedAt = Date()
        try story.update(db)
        return story
    }

    public static func move(
        db: Database,
        storyId: Int64,
        targetColumnId: Int64,
        position: Int
    ) throws -> Story {
        guard var story = try Story.fetchOne(db, key: storyId) else {
            throw DatabaseError(message: "Story not found: \(storyId)")
        }

        let sourceColumnId = story.boardColumnId
        let sourcePosition = story.position

        if sourceColumnId == targetColumnId {
            // Moving within the same column
            if sourcePosition == position {
                return story
            }

            if sourcePosition < position {
                // Moving down: shift stories between old and new position up
                try Story
                    .filter(Story.Columns.boardColumnId == sourceColumnId)
                    .filter(Story.Columns.position > sourcePosition)
                    .filter(Story.Columns.position <= position)
                    .updateAll(db, Story.Columns.position -= 1)
            } else {
                // Moving up: shift stories between new and old position down
                try Story
                    .filter(Story.Columns.boardColumnId == sourceColumnId)
                    .filter(Story.Columns.position >= position)
                    .filter(Story.Columns.position < sourcePosition)
                    .updateAll(db, Story.Columns.position += 1)
            }
        } else {
            // Moving to a different column
            // Shift stories above source position down in source column
            try Story
                .filter(Story.Columns.boardColumnId == sourceColumnId)
                .filter(Story.Columns.position > sourcePosition)
                .updateAll(db, Story.Columns.position -= 1)

            // Shift stories at or above target position up in target column
            try Story
                .filter(Story.Columns.boardColumnId == targetColumnId)
                .filter(Story.Columns.position >= position)
                .updateAll(db, Story.Columns.position += 1)

            story.boardColumnId = targetColumnId
        }

        story.position = position
        story.updatedAt = Date()
        try story.update(db)
        return story
    }

    public static func delete(db: Database, id: Int64) throws -> Bool {
        try Story.deleteOne(db, key: id)
    }
}
