// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DevPreview",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DevPreview",
            targets: ["DevPreview"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoRepository"),
        .package(path: "../TodoUseCase"),
        .package(path: "../TodoListView"),
        .package(path: "../TodoDetailView")
    ],
    targets: [
        .target(
            name: "DevPreview",
            dependencies: [
                "DependencyContainer",
                "TodoRepository",
                "TodoUseCase",
                "TodoListView",
                "TodoDetailView"
            ]
        ),
        .testTarget(
            name: "DevPreviewTests",
            dependencies: ["DevPreview"]
        )
    ]
)
