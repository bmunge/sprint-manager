import Foundation

/// Posts and observes Darwin notifications so the app and MCP server
/// can tell each other when the database has changed.
public enum CrossProcessNotifier {
    private static let notificationName = "com.sprintmanager.database-changed" as CFString

    /// Post a Darwin notification that the database changed.
    /// Call this from the MCP server after every write.
    public static func postDidChange() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(center, CFNotificationName(notificationName), nil, nil, true)
    }

    /// Start observing Darwin notifications. The handler is called on an
    /// arbitrary thread whenever another process posts a change notification.
    /// Call this from the app on launch.
    public static func startObserving(handler: @escaping () -> Void) {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(Storage.shared).toOpaque())
        Storage.shared.handler = handler
        CFNotificationCenterAddObserver(
            center,
            observer,
            { _, observer, _, _, _ in
                Storage.shared.handler?()
            },
            notificationName,
            nil,
            .deliverImmediately
        )
    }

    // Storage to prevent the closure from being deallocated
    private final class Storage {
        static let shared = Storage()
        var handler: (() -> Void)?
    }
}
