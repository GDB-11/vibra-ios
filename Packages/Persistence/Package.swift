// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(name: "Persistence", targets: ["Persistence"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "Domain", package: "Domain")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
