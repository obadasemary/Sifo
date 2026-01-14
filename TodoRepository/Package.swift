// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoRepository",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "TodoRepository",
            targets: ["TodoRepository"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "TodoRepository",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "TodoRepositoryTests",
            dependencies: [
                "TodoRepository",
                "TodoUseCase"
            ]
        )
    ]
)
