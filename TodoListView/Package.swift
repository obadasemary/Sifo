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
        .package(path: "../TodoUI"),
        .package(path: "../DevPreview")
    ],
    targets: [
        .target(
            name: "TodoListView",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase",
                "TodoUI",
                "DevPreview"
            ]
        ),
        .testTarget(
            name: "TodoListViewTests",
            dependencies: ["TodoListView"]
        )
    ]
)
