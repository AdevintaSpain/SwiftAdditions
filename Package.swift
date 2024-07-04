// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Additions",
    platforms: [
        .iOS(.v15)
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
        .target(
            name: "AdditionsTestHelpers",
            dependencies: [
                .target(name: "Additions")
            ],
            path: "SwiftAdditions/AdditionsTestHelpers"
        ),
        .testTarget(
            name: "AdditionsTests",
            dependencies: [
                .target(name: "Additions"),
                .target(name: "AdditionsTestHelpers"),
            ],
            path: "SwiftAdditions/Tests"
        )
    ]
)
