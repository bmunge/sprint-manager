import SwiftUI
import GRDB
import SprintManagerKit

@main
struct SprintManagerApp: App {
    let dbPool: DatabasePool

    init() {
        do {
            dbPool = try AppDatabase.makeDatabasePool(at: DatabasePath.databasePath)
        } catch {
            fatalError("Database setup failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.database, dbPool)
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}

// MARK: - Database Environment Key

private struct DatabaseKey: EnvironmentKey {
    static let defaultValue: (any DatabaseWriter)? = nil
}

extension EnvironmentValues {
    var database: (any DatabaseWriter)? {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}
