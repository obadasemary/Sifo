// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "TodoUI",
            targets: ["TodoUI"]
        )
    ],
    dependencies: [
        .package(path: "../TodoRepository"),
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "TodoUI",
            dependencies: [
                "TodoRepository",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "TodoUITests",
            dependencies: ["TodoUI"]
        )
    ]
)
