// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDeepLinking",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SwiftDeepLinking",
            targets: ["SwiftDeepLinking"]),
        .library(
            name: "SwiftDeepLinkingSwiftUI",
            targets: ["SwiftDeepLinkingSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aim2120/SwiftParameterPackExtras.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "SwiftDeepLinking",
            dependencies: [
                .product(name: "SwiftParameterPackExtras", package: "SwiftParameterPackExtras"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
            ]
        ),
        .target(
            name: "SwiftDeepLinkingSwiftUI",
            dependencies: [
                "SwiftDeepLinking",
                .product(name: "SwiftParameterPackExtras", package: "SwiftParameterPackExtras"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "SwiftDeepLinkingTests",
            dependencies: [
                "SwiftDeepLinking",
                .product(name: "SwiftParameterPackExtras", package: "SwiftParameterPackExtras"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "SwiftDeepLinkingSwiftUITests",
            dependencies: [
                "SwiftDeepLinking",
                "SwiftDeepLinkingSwiftUI",
                .product(name: "SwiftParameterPackExtras", package: "SwiftParameterPackExtras"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
    ]
)
