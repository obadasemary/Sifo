// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TabBarView",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "TabBarView",
            targets: ["TabBarView"]
        )
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../TodoListView"),
        .package(path: "../TodoDetailView")
    ],
    targets: [
        .target(
            name: "TabBarView",
            dependencies: [
                "DependencyContainer",
                "TodoListView",
                "TodoDetailView"
            ]
        ),
        .testTarget(
            name: "TabBarViewTests",
            dependencies: ["TabBarView"]
        )
    ]
)
