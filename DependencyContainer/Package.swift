// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DependencyContainer",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DependencyContainer",
            targets: ["DependencyContainer"]
        )
    ],
    targets: [
        .target(
            name: "DependencyContainer"
        ),
        .testTarget(
            name: "DependencyContainerTests",
            dependencies: ["DependencyContainer"]
        )
    ]
)
