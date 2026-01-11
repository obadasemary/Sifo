// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoListView",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "TodoListView",
            targets: ["TodoListView"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase"),
        .package(path: "../TodoUI")
    ],
    targets: [
        .target(
            name: "TodoListView",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase",
                "TodoUI"
            ]
        ),
        .testTarget(
            name: "TodoListViewTests",
            dependencies: ["TodoListView"]
        )
    ]
)
