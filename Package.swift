// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FMChatsServer",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        // Vapor framework for building web APIs
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
    ],
    targets: [
        .executableTarget(
            name: "FMChatsServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        )
    ]
)
