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
        .package(path: "../TodoUseCase")
    ],
    targets: [
        .target(
            name: "DevPreview",
            dependencies: [
                "DependencyContainer",
                "TodoRepository",
                "TodoUseCase"
            ]
        ),
        .testTarget(
            name: "DevPreviewTests",
            dependencies: ["DevPreview"]
        )
    ]
)
