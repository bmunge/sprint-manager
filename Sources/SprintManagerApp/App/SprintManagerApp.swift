import SwiftUI
import AppKit
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

        // SPM executables aren't .app bundles, so macOS won't activate them.
        // This forces Dock presence, menu bar, and key focus.
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)

        // Set the app icon from bundled resource
        if let iconURL = Bundle.module.url(forResource: "AppIcon", withExtension: "icns"),
           let icon = NSImage(contentsOf: iconURL) {
            NSApplication.shared.applicationIconImage = icon
        }

        // Listen for cross-process writes (e.g. from MCP server) and tell
        // GRDB to re-check the database so ValueObservations refresh.
        let pool = dbPool
        CrossProcessNotifier.startObserving {
            try? pool.write { db in
                try db.notifyChanges(in: .fullDatabase)
            }
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
