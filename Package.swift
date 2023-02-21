// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Additions",
    platforms: [
        .iOS(.v13)
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
        )
    ]
)
