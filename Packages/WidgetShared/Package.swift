// swift-tools-version: 6.2
import PackageDescription

// Tipos que comparten la app y la extensión de widgets.
let package = Package(
    name: "WidgetShared",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(name: "WidgetShared", targets: ["WidgetShared"])
    ],
    targets: [
        .target(
            name: "WidgetShared"
        )
    ],
    swiftLanguageModes: [.v6]
)
