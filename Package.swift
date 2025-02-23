// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DangerSwiftKantoku",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DangerSwiftKantoku",
            targets: ["DangerSwiftKantoku"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift", from: "3.21.1"),
        .package(url: "https://github.com/davidahouse/XCResultKit", from: "1.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DangerSwiftKantoku",
            dependencies: [
                .product(name: "Danger", package: "swift"),
                "XCResultKit",
            ]),
        .testTarget(
            name: "DangerSwiftKantokuTests",
            dependencies: ["DangerSwiftKantoku"]),
    ]
)
