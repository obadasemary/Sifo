// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TodoUseCase",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "TodoUseCase",
            targets: ["TodoUseCase"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer")
    ],
    targets: [
        .target(
            name: "TodoUseCase",
            dependencies: [
                "DependencyContainer"
            ]
        ),
        .testTarget(
            name: "TodoUseCaseTests",
            dependencies: ["TodoUseCase"]
        )
    ]
)
