// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(name: "Networking", targets: ["Networking"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "Domain", package: "Domain")
            ],
            // El contrato se sincroniza con scripts/sync-contract.sh. Quita esta exclusión
            // al añadir swift-openapi-generator, que necesita ver el archivo.
            exclude: ["openapi.json"]
        )
    ],
    swiftLanguageModes: [.v6]
)
