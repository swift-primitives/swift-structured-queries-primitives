// swift-tools-version: 6.3.3
import PackageDescription

let package = Package(
    name: "swift-structured-queries-primitives",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27"),
        .visionOS("27"),
    ],
    products: [
        .library(
            name: "Structured Queries Primitives",
            targets: ["Structured Queries Primitives"]
        ),
        .library(
            name: "Structured Queries Primitives Support",
            targets: ["Structured Queries Primitives Support"]
        ),
        .library(
            name: "Structured Queries Primitives Foundation Integration",
            targets: ["Structured Queries Primitives Foundation Integration"]
        ),
        .library(
            name: "Structured Queries Primitives Test Support",
            targets: ["Structured Queries Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-tagged-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-time-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        // MARK: - Core
        .target(
            name: "Structured Queries Primitives",
            dependencies: [
                "Structured Queries Primitives Support",
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Time Primitives", package: "swift-time-primitives"),
            ]
        ),

        // MARK: - Support
        .target(
            name: "Structured Queries Primitives Support",
            dependencies: []
        ),

        // MARK: - Foundation Integration (opt-in leaf; no core/Support target depends on it)
        .target(
            name: "Structured Queries Primitives Foundation Integration",
            dependencies: [
                "Structured Queries Primitives",
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Time Primitives", package: "swift-time-primitives"),
            ]
        ),

        // MARK: - Tests
        .target(
            name: "Structured Queries Primitives Test Support",
            dependencies: [
                "Structured Queries Primitives",
                .product(
                    name: "Tagged Primitives Test Support",
                    package: "swift-tagged-primitives"
                ),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Structured Queries Primitives Tests",
            dependencies: [
                "Structured Queries Primitives",
                "Structured Queries Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
