import Testing
import GRDB
@testable import SprintManagerKit

struct SprintManagerKitTests {
    func makeDatabase() throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(dbQueue)
        return dbQueue
    }

    // MARK: - Board Tests

    @Test func createBoardWithDefaultColumns() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "My Board")
            #expect(board.id != nil)
            #expect(board.name == "My Board")

            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            #expect(columns.count == 4)
            #expect(columns[0].name == "To Do")
            #expect(columns[1].name == "In Progress")
            #expect(columns[2].name == "In Review")
            #expect(columns[3].name == "Done")
            #expect(columns[0].position == 0)
            #expect(columns[3].position == 3)
        }
    }

    @Test func fetchAllBoardsOrderedByCreatedAt() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            _ = try BoardQueries.create(db: db, name: "Board A")
            _ = try BoardQueries.create(db: db, name: "Board B")
            let boards = try BoardQueries.fetchAll(db: db)
            #expect(boards.count == 2)
            #expect(boards[0].name == "Board A")
            #expect(boards[1].name == "Board B")
        }
    }

    @Test func deleteBoardCascadesColumnsAndStories() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "To Delete")
            let boardId = board.id!
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: boardId)
            let columnId = columns[0].id!
            _ = try StoryQueries.create(db: db, columnId: columnId, title: "Story 1", description: nil)

            let deleted = try BoardQueries.delete(db: db, id: boardId)
            #expect(deleted)

            let remainingBoards = try BoardQueries.fetchAll(db: db)
            #expect(remainingBoards.isEmpty)

            let remainingColumns = try ColumnQueries.fetchForBoard(db: db, boardId: boardId)
            #expect(remainingColumns.isEmpty)

            let remainingStories = try StoryQueries.fetchForColumn(db: db, columnId: columnId)
            #expect(remainingStories.isEmpty)
        }
    }

    @Test func deleteNonExistentBoard() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let deleted = try BoardQueries.delete(db: db, id: 9999)
            #expect(!deleted)
        }
    }

    // MARK: - Column Tests

    @Test func createColumnPositionIsMaxPlusOne() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let boardId = board.id!

            let newColumn = try ColumnQueries.create(db: db, boardId: boardId, name: "Extra")
            #expect(newColumn.position == 4) // 4 defaults at 0-3, so next is 4
        }
    }

    @Test func fetchColumnsOrderedByPosition() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let positions = columns.map { $0.position }
            #expect(positions == positions.sorted())
        }
    }

    // MARK: - Story Tests

    @Test func createStory() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let story = try StoryQueries.create(db: db, columnId: columnId, title: "Story 1", description: "Desc")
            #expect(story.id != nil)
            #expect(story.title == "Story 1")
            #expect(story.description == "Desc")
            #expect(story.position == 0)
            #expect(story.boardColumnId == columnId)
        }
    }

    @Test func createMultipleStoriesPositionIncrement() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let s1 = try StoryQueries.create(db: db, columnId: columnId, title: "Story 1", description: nil)
            let s2 = try StoryQueries.create(db: db, columnId: columnId, title: "Story 2", description: nil)
            let s3 = try StoryQueries.create(db: db, columnId: columnId, title: "Story 3", description: nil)

            #expect(s1.position == 0)
            #expect(s2.position == 1)
            #expect(s3.position == 2)
        }
    }

    @Test func updateStory() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let story = try StoryQueries.create(db: db, columnId: columnId, title: "Original", description: nil)
            let updated = try StoryQueries.update(db: db, storyId: story.id!, title: "Updated", description: "New desc")

            #expect(updated.title == "Updated")
            #expect(updated.description == "New desc")
        }
    }

    @Test func updateStoryPartial() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let story = try StoryQueries.create(db: db, columnId: columnId, title: "Original", description: "Keep")
            let updated = try StoryQueries.update(db: db, storyId: story.id!, title: "New Title", description: nil)

            #expect(updated.title == "New Title")
            #expect(updated.description == "Keep")
        }
    }

    @Test func deleteStory() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let story = try StoryQueries.create(db: db, columnId: columnId, title: "Story", description: nil)
            let deleted = try StoryQueries.delete(db: db, id: story.id!)
            #expect(deleted)

            let stories = try StoryQueries.fetchForColumn(db: db, columnId: columnId)
            #expect(stories.isEmpty)
        }
    }

    @Test func fetchStoriesForBoard() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)

            _ = try StoryQueries.create(db: db, columnId: columns[0].id!, title: "S1", description: nil)
            _ = try StoryQueries.create(db: db, columnId: columns[1].id!, title: "S2", description: nil)
            _ = try StoryQueries.create(db: db, columnId: columns[0].id!, title: "S3", description: nil)

            let stories = try StoryQueries.fetchForBoard(db: db, boardId: board.id!)
            #expect(stories.count == 3)
        }
    }

    // MARK: - Story Move Tests

    @Test func moveStoryBetweenColumns() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let col1Id = columns[0].id!
            let col2Id = columns[1].id!

            let s1 = try StoryQueries.create(db: db, columnId: col1Id, title: "S1", description: nil)
            let s2 = try StoryQueries.create(db: db, columnId: col1Id, title: "S2", description: nil)
            _ = try StoryQueries.create(db: db, columnId: col2Id, title: "S3", description: nil)

            let moved = try StoryQueries.move(db: db, storyId: s1.id!, targetColumnId: col2Id, position: 0)
            #expect(moved.boardColumnId == col2Id)
            #expect(moved.position == 0)

            let col1Stories = try StoryQueries.fetchForColumn(db: db, columnId: col1Id)
            #expect(col1Stories.count == 1)
            #expect(col1Stories[0].id == s2.id)
            #expect(col1Stories[0].position == 0)

            let col2Stories = try StoryQueries.fetchForColumn(db: db, columnId: col2Id)
            #expect(col2Stories.count == 2)
            #expect(col2Stories[0].id == s1.id)
            #expect(col2Stories[0].position == 0)
            #expect(col2Stories[1].position == 1)
        }
    }

    @Test func moveStoryWithinSameColumnDown() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let colId = columns[0].id!

            let s1 = try StoryQueries.create(db: db, columnId: colId, title: "S1", description: nil)
            let s2 = try StoryQueries.create(db: db, columnId: colId, title: "S2", description: nil)
            let s3 = try StoryQueries.create(db: db, columnId: colId, title: "S3", description: nil)

            _ = try StoryQueries.move(db: db, storyId: s1.id!, targetColumnId: colId, position: 2)

            let stories = try StoryQueries.fetchForColumn(db: db, columnId: colId)
            #expect(stories[0].id == s2.id)
            #expect(stories[0].position == 0)
            #expect(stories[1].id == s3.id)
            #expect(stories[1].position == 1)
            #expect(stories[2].id == s1.id)
            #expect(stories[2].position == 2)
        }
    }

    @Test func moveStoryWithinSameColumnUp() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let colId = columns[0].id!

            let s1 = try StoryQueries.create(db: db, columnId: colId, title: "S1", description: nil)
            let s2 = try StoryQueries.create(db: db, columnId: colId, title: "S2", description: nil)
            let s3 = try StoryQueries.create(db: db, columnId: colId, title: "S3", description: nil)

            _ = try StoryQueries.move(db: db, storyId: s3.id!, targetColumnId: colId, position: 0)

            let stories = try StoryQueries.fetchForColumn(db: db, columnId: colId)
            #expect(stories[0].id == s3.id)
            #expect(stories[0].position == 0)
            #expect(stories[1].id == s1.id)
            #expect(stories[1].position == 1)
            #expect(stories[2].id == s2.id)
            #expect(stories[2].position == 2)
        }
    }

    // MARK: - Sprint Tests

    @Test func createSprint() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let sprint = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1", goal: "Ship it")
            #expect(sprint.id != nil)
            #expect(sprint.name == "Sprint 1")
            #expect(sprint.goal == "Ship it")
            #expect(sprint.isActive == false)
            #expect(sprint.boardId == board.id)
        }
    }

    @Test func fetchSprintsForBoard() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            _ = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1")
            _ = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 2")
            let sprints = try SprintQueries.fetchForBoard(db: db, boardId: board.id!)
            #expect(sprints.count == 2)
        }
    }

    @Test func onlyOneActiveSprintPerBoard() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let s1 = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1")
            let s2 = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 2")

            _ = try SprintQueries.start(db: db, sprintId: s1.id!)
            var active = try SprintQueries.fetchActive(db: db, boardId: board.id!)
            #expect(active?.id == s1.id)

            // Starting s2 should deactivate s1
            _ = try SprintQueries.start(db: db, sprintId: s2.id!)
            active = try SprintQueries.fetchActive(db: db, boardId: board.id!)
            #expect(active?.id == s2.id)

            // s1 should no longer be active
            let s1Refreshed = try Sprint.fetchOne(db, key: s1.id!)
            #expect(s1Refreshed?.isActive == false)
        }
    }

    @Test func completeSprintMovesIncompleteStoriesToBacklog() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let todoId = columns[0].id! // To Do
            let doneId = columns[3].id! // Done

            let sprint = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1")
            _ = try SprintQueries.start(db: db, sprintId: sprint.id!)

            // Create stories in the sprint
            let incomplete = try StoryQueries.create(db: db, columnId: todoId, title: "Not Done", description: nil, sprintId: sprint.id!)
            let complete = try StoryQueries.create(db: db, columnId: doneId, title: "Done", description: nil, sprintId: sprint.id!)

            _ = try SprintQueries.complete(db: db, sprintId: sprint.id!)

            // Incomplete story should be back in backlog (sprintId nil)
            let incompleteRefreshed = try Story.fetchOne(db, key: incomplete.id!)
            #expect(incompleteRefreshed?.sprintId == nil)

            // Complete story should keep its sprintId
            let completeRefreshed = try Story.fetchOne(db, key: complete.id!)
            #expect(completeRefreshed?.sprintId == sprint.id)
        }
    }

    @Test func deleteSprintSetsStoriesBackToBacklog() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let sprint = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1")
            let story = try StoryQueries.create(db: db, columnId: columnId, title: "Story", description: nil, sprintId: sprint.id!)

            _ = try SprintQueries.delete(db: db, id: sprint.id!)

            let refreshed = try Story.fetchOne(db, key: story.id!)
            #expect(refreshed?.sprintId == nil)
        }
    }

    @Test func assignStoryToSprint() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let sprint = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1")
            let story = try StoryQueries.create(db: db, columnId: columnId, title: "Story", description: nil)
            #expect(story.sprintId == nil)

            let assigned = try StoryQueries.assignToSprint(db: db, storyId: story.id!, sprintId: sprint.id!)
            #expect(assigned.sprintId == sprint.id)

            // Unassign from sprint
            let unassigned = try StoryQueries.assignToSprint(db: db, storyId: story.id!, sprintId: nil)
            #expect(unassigned.sprintId == nil)
        }
    }

    @Test func fetchBacklog() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let columnId = columns[0].id!

            let sprint = try SprintQueries.create(db: db, boardId: board.id!, name: "Sprint 1")
            _ = try StoryQueries.create(db: db, columnId: columnId, title: "In Sprint", description: nil, sprintId: sprint.id!)
            _ = try StoryQueries.create(db: db, columnId: columnId, title: "Backlog 1", description: nil)
            _ = try StoryQueries.create(db: db, columnId: columnId, title: "Backlog 2", description: nil)

            let backlog = try StoryQueries.fetchBacklog(db: db, boardId: board.id!)
            #expect(backlog.count == 2)
            #expect(backlog.allSatisfy { $0.sprintId == nil })
        }
    }

    @Test func moveStoryWithinSameColumnNoOp() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db in
            let board = try BoardQueries.create(db: db, name: "Board")
            let columns = try ColumnQueries.fetchForBoard(db: db, boardId: board.id!)
            let colId = columns[0].id!

            let s1 = try StoryQueries.create(db: db, columnId: colId, title: "S1", description: nil)
            _ = try StoryQueries.create(db: db, columnId: colId, title: "S2", description: nil)

            let result = try StoryQueries.move(db: db, storyId: s1.id!, targetColumnId: colId, position: 0)
            #expect(result.position == 0)
            #expect(result.boardColumnId == colId)
        }
    }
}
