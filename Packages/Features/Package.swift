// swift-tools-version: 6.2
import PackageDescription

// Cada funcionalidad es un objetivo independiente: solo depende de Domain y DesignSystem,
// nunca de otra funcionalidad. El sufijo "Feature" evita que el objetivo de la tienda
// choque con el módulo del paquete Store.
let featureNames = [
    "Auth",
    "Home",
    "Search",
    "Library",
    "Player",
    "Store",
    "Subscription",
    "Settings"
]

let package = Package(
    name: "Features",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(name: "Features", targets: featureNames.map { "\($0)Feature" })
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../DesignSystem")
    ],
    targets: featureNames.map { name in
        .target(
            name: "\(name)Feature",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "DesignSystem", package: "DesignSystem")
            ],
            path: "Sources/\(name)"
        )
    } + [
        .testTarget(
            name: "FeaturesTests",
            dependencies: featureNames.map { .target(name: "\($0)Feature") } + [
                .product(name: "Domain", package: "Domain")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
