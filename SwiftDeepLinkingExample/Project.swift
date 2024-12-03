import ProjectDescription

private func bundleID(_ name: String) -> String {
    "com.aim2120.\(name)"
}

extension Set<Destination> {
    fileprivate static let libraryDestinations: Self = Set(Destination.allCases)
}

extension DeploymentTargets {
    fileprivate static let libraryDeploymentTargets: Self = .multiplatform(
        iOS: "17.0",
        macOS: "14.0",
        watchOS: "10.0",
        tvOS: "17.0",
        visionOS: "1.0"
    )
}

extension Target {
    fileprivate static func libraryTarget(
        name: String,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: .libraryDestinations,
            product: .staticLibrary,
            bundleId: bundleID(name),
            deploymentTargets: .libraryDeploymentTargets,
            sources: ["../Sources/\(name)/**"],
            dependencies: dependencies
        )
    }

    fileprivate static func testTarget(
        testing name: String,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: "\(name)Tests",
            destinations: .libraryDestinations,
            product: .unitTests,
            bundleId: bundleID("\(name)Tests"),
            deploymentTargets: .libraryDeploymentTargets,
            sources: ["../Tests/\(name)Tests/**"],
            dependencies: [
                .target(name: name),
            ] + dependencies
        )
    }
}

let project = Project(
    name: "SwiftDeepLinkingExample",
    packages: [
        .remote(url: "https://github.com/aim2120/SwiftParameterPackExtras.git", requirement: .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "SwiftDeepLinkingExample",
            destinations: .iOS,
            product: .app,
            bundleId: bundleID("SwiftDeepLinkingExample"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["SwiftDeepLinkingExample/Sources/**"],
            resources: ["SwiftDeepLinkingExample/Resources/**"],
            dependencies: [
                .target(name: "SwiftDeepLinking"),
                .target(name: "SwiftDeepLinkingSwiftUI"),
            ]
        ),
        .libraryTarget(
            name: "SwiftDeepLinking",
            dependencies: [
                .package(product: "SwiftParameterPackExtras"),
            ]
        ),
        .libraryTarget(
            name: "SwiftDeepLinkingSwiftUI",
            dependencies: [
                .package(product: "SwiftParameterPackExtras"),
                .target(name: "SwiftDeepLinking"),
            ]
        ),
        .testTarget(
            testing: "SwiftDeepLinking",
            dependencies: [
                .package(product: "SwiftParameterPackExtras"),
            ]
        ),
        .testTarget(
            testing: "SwiftDeepLinkingSwiftUI",
            dependencies: [
                .package(product: "SwiftParameterPackExtras"),
            ]
        ),
    ]
)
