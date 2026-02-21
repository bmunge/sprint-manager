// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SprintManager",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SprintManagerKit", targets: ["SprintManagerKit"]),
        .executable(name: "SprintManagerMCP", targets: ["SprintManagerMCP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.4.1"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.9.2"),
    ],
    targets: [
        .target(
            name: "SprintManagerKit",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .executableTarget(
            name: "SprintManagerApp",
            dependencies: [
                "SprintManagerKit",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .executableTarget(
            name: "SprintManagerMCP",
            dependencies: [
                "SprintManagerKit",
                .product(name: "MCP", package: "swift-sdk"),
            ]
        ),
        .testTarget(
            name: "SprintManagerKitTests",
            dependencies: ["SprintManagerKit"]
        ),
    ]
)
