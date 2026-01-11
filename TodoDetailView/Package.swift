// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoDetailView",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "TodoDetailView",
            targets: ["TodoDetailView"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoUseCase"),
        .package(path: "../TodoUI")
    ],
    targets: [
        .target(
            name: "TodoDetailView",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase",
                "TodoUI"
            ]
        ),
        .testTarget(
            name: "TodoDetailViewTests",
            dependencies: ["TodoDetailView"]
        )
    ]
)
