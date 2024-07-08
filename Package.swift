// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Additions",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Additions",
            targets: ["Additions"]
        )
    ],
    targets: [
        .target(
            name: "Additions",
            dependencies: [],
            path: "SwiftAdditions/Classes"
        ),
        .testTarget(
            name: "AdditionsTests",
            dependencies: [
                .target(name: "Additions"),
            ],
            path: "SwiftAdditions/Tests"
        )
    ]
)
