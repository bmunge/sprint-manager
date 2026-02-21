import MCP
import SprintManagerKit
import Foundation

let server = Server(
    name: "sprint-manager",
    version: "1.0.0",
    capabilities: Server.Capabilities(tools: .init())
)

let dbPath = DatabasePath.databasePath

await server.withMethodHandler(ListTools.self) { _ in
    .init(tools: MCPToolRegistry.allTools)
}

await server.withMethodHandler(CallTool.self) { params in
    do {
        let dbQueue = try AppDatabase.makeDatabaseQueue(at: dbPath)
        return try handleToolCall(params: params, db: dbQueue)
    } catch {
        return .init(content: [.text("Error: \(error.localizedDescription)")], isError: true)
    }
}

let transport = StdioTransport()
try await server.start(transport: transport)
await server.waitUntilCompleted()
