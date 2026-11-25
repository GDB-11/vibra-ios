// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Playback",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(name: "Playback", targets: ["Playback"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Playback",
            dependencies: [
                .product(name: "Domain", package: "Domain")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
