// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Store",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(name: "Store", targets: ["Store"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Store",
            dependencies: [
                .product(name: "Domain", package: "Domain")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
