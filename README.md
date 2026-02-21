# Sprint Manager

A Trello-like macOS sprint board with an MCP server, so Claude Code sessions can create, update, and move stories natively. The SwiftUI app and MCP server share a SQLite database — changes from either side appear live.

## Prerequisites

- macOS 14+
- Swift 5.9+ (included with Xcode or Command Line Tools)

## Setup

```bash
git clone https://github.com/bmunge/sprint-manager.git
cd sprint-manager
swift build
```

## Run the App

```bash
swift run SprintManagerApp
```

## Connect Claude Code (MCP)

Add this to `.mcp.json` in any project where you want Claude to manage your sprint board:

```json
{
  "mcpServers": {
    "sprint-manager": {
      "command": "swift",
      "args": ["run", "--package-path", "/absolute/path/to/sprint-manager", "SprintManagerMCP"]
    }
  }
}
```

Replace `/absolute/path/to/sprint-manager` with the actual path to your clone.

Alternatively, for faster startup, build once and point directly at the binary:

```json
{
  "mcpServers": {
    "sprint-manager": {
      "command": "/absolute/path/to/sprint-manager/.build/debug/SprintManagerMCP"
    }
  }
}
```

After adding the config, restart Claude Code. The tools will be available immediately.

## MCP Tools

| Tool | Description |
|------|-------------|
| `list_boards` | List all sprint boards |
| `create_board` | Create a board with default columns (To Do, In Progress, In Review, Done) |
| `delete_board` | Delete a board and all its columns/stories |
| `list_columns` | List columns for a board |
| `create_column` | Add a column to a board |
| `list_stories` | List stories by board or column |
| `create_story` | Create a story in a column |
| `update_story` | Update a story's title/description |
| `move_story` | Move a story to a different column/position |
| `delete_story` | Delete a story |

## Architecture

```
Sources/
  SprintManagerKit/    # Shared library — models, migrations, queries
  SprintManagerApp/    # SwiftUI macOS app (kanban board)
  SprintManagerMCP/    # MCP stdio server (10 tools)
Tests/
  SprintManagerKitTests/
```

All three targets share `SprintManagerKit`. The app uses `DatabasePool` (WAL mode) for concurrent reads; the MCP server uses `DatabaseQueue`. Both point at the same SQLite file in `~/Library/Application Support/SprintManager/`.

## Tests

```bash
swift test
```
