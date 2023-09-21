// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Library",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Haptics",
            targets: ["Haptics"]
        ),
        .library(
            name: "Library",
            targets: ["Library"]
        ),
        .library(
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "Platform",
            targets: ["Platform"]
        ),
        .library(
            name: "UI",
            targets: ["UI"]
        ),
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "0.3.0"
        ),
        .package(url: "https://github.com/kean/Nuke.git", from: "12.1.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Haptics",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "Utility"
            ]
        ),
        .target(
            name: "Library",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Model",
                "Platform",
                "UI",
                "Utility"
            ]
        ),
        .testTarget(
            name: "LibraryTests",
            dependencies: ["Library"]
        ),
        .target(
            name: "Model"
        ),
        .target(
            name: "Platform",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .target(
            name: "UI",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NukeUI", package: "Nuke"),
                "Haptics",
                "Platform",
                "Model",
                "Utility"
            ]
        ),
        .target(
            name: "Utility",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
    ]
)
