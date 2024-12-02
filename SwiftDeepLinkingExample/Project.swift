import ProjectDescription

private func bundleID(_ name: String) -> String {
    "com.aim2120.\(name)"
}

let project = Project(
    name: "SwiftDeepLinkingExample",
    packages: [
        .local(path: ".."),
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
                .package(product: "SwiftDeepLinking"),
                .package(product: "SwiftDeepLinkingSwiftUI"),
            ]
        ),
    ]
)
