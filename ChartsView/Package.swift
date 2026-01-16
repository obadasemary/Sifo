// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChartsView",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ChartsView",
            targets: ["ChartsView"]
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
            name: "ChartsView",
            dependencies: [
                "DependencyContainer",
                "TodoUseCase",
                "TodoUI",
                "DevPreview"
            ]
        ),
        .testTarget(
            name: "ChartsViewTests",
            dependencies: ["ChartsView"]
        )
    ]
)
