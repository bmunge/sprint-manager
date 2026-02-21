import MCP

enum MCPToolRegistry {
    static let allTools: [Tool] = [
        Tool(
            name: "list_boards",
            description: "List all sprint boards",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:])
            ])
        ),
        Tool(
            name: "create_board",
            description: "Create a new sprint board with default columns (To Do, In Progress, In Review, Done)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "name": .object([
                        "type": .string("string"),
                        "description": .string("Board name")
                    ])
                ]),
                "required": .array([.string("name")])
            ])
        ),
        Tool(
            name: "delete_board",
            description: "Delete a sprint board and all its columns and stories",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "boardId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the board to delete")
                    ])
                ]),
                "required": .array([.string("boardId")])
            ])
        ),
        Tool(
            name: "list_columns",
            description: "List all columns for a given board",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "boardId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the board")
                    ])
                ]),
                "required": .array([.string("boardId")])
            ])
        ),
        Tool(
            name: "create_column",
            description: "Create a new column in a board",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "boardId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the board")
                    ]),
                    "name": .object([
                        "type": .string("string"),
                        "description": .string("Column name")
                    ])
                ]),
                "required": .array([.string("boardId"), .string("name")])
            ])
        ),
        Tool(
            name: "list_stories",
            description: "List stories for a board or column. At least one of boardId or columnId is required.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "boardId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the board (returns all stories across columns)")
                    ]),
                    "columnId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the column (returns stories in that column)")
                    ])
                ])
            ])
        ),
        Tool(
            name: "create_story",
            description: "Create a new story in a column",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "columnId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the column")
                    ]),
                    "title": .object([
                        "type": .string("string"),
                        "description": .string("Story title")
                    ]),
                    "description": .object([
                        "type": .string("string"),
                        "description": .string("Story description (optional)")
                    ]),
                    "sprintId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the sprint to assign to (optional)")
                    ])
                ]),
                "required": .array([.string("columnId"), .string("title")])
            ])
        ),
        Tool(
            name: "update_story",
            description: "Update a story's title and/or description",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "storyId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the story to update")
                    ]),
                    "title": .object([
                        "type": .string("string"),
                        "description": .string("New title (optional)")
                    ]),
                    "description": .object([
                        "type": .string("string"),
                        "description": .string("New description (optional)")
                    ])
                ]),
                "required": .array([.string("storyId")])
            ])
        ),
        Tool(
            name: "move_story",
            description: "Move a story to a different column and/or position",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "storyId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the story to move")
                    ]),
                    "targetColumnId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the target column")
                    ]),
                    "position": .object([
                        "type": .string("integer"),
                        "description": .string("Target position (0-based)")
                    ])
                ]),
                "required": .array([.string("storyId"), .string("targetColumnId"), .string("position")])
            ])
        ),
        Tool(
            name: "delete_story",
            description: "Delete a story",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "storyId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the story to delete")
                    ])
                ]),
                "required": .array([.string("storyId")])
            ])
        ),
        Tool(
            name: "list_sprints",
            description: "List all sprints for a board",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "boardId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the board")
                    ])
                ]),
                "required": .array([.string("boardId")])
            ])
        ),
        Tool(
            name: "create_sprint",
            description: "Create a new sprint for a board (inactive by default)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "boardId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the board")
                    ]),
                    "name": .object([
                        "type": .string("string"),
                        "description": .string("Sprint name")
                    ]),
                    "goal": .object([
                        "type": .string("string"),
                        "description": .string("Sprint goal (optional)")
                    ])
                ]),
                "required": .array([.string("boardId"), .string("name")])
            ])
        ),
        Tool(
            name: "start_sprint",
            description: "Activate a sprint (deactivates any other active sprint on the same board)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "sprintId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the sprint to start")
                    ])
                ]),
                "required": .array([.string("sprintId")])
            ])
        ),
        Tool(
            name: "complete_sprint",
            description: "Complete a sprint. Incomplete stories are moved back to backlog.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "sprintId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the sprint to complete")
                    ])
                ]),
                "required": .array([.string("sprintId")])
            ])
        ),
        Tool(
            name: "assign_story_to_sprint",
            description: "Assign a story to a sprint, or remove from sprint (set to backlog)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "storyId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the story")
                    ]),
                    "sprintId": .object([
                        "type": .string("integer"),
                        "description": .string("ID of the sprint (omit or null to move to backlog)")
                    ])
                ]),
                "required": .array([.string("storyId")])
            ])
        )
    ]
}
