# SwiftDeepLinking

Implement universal and URL scheme deep links with a composable DSL.

## Requirements

Language:
- Swift v6+

Platforms:
- macOS v14+
- iOS v17+
- tvOS v17+
- watchOS v10+
- visionOS v1+

## Installation

This package is distributed via SPM.

You can add this package as a dependency by adding the following lines to your Package.swift

```swift
dependencies: [
    // package dependency
    .package(url: "https://github.com/aim2120/SwiftDeepLinking.git", from: "0.1.0")
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            // target dependency
            .product(name: "SwiftDeepLinking", package: "SwiftDeepLinking")
        ]
    )
]
```

You can also add this directly to an Xcode project by following [Apple's instructions](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

## Example Usage

```swift
import SwiftUI
import SwiftDeepLinking
import SwiftDeepLinkingSwiftUI

struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @State private var metadata: Metadata?

    private func parse(link: DeepLink) {
        do {
            let parsedLink = try link
                .parseLeadingSlash()
                .parse {
                    Parsers {
                        EnumPathParser(TabPage.self)
                        Optionally {
                            EnumPathParser(SubPage.self)
                        }
                    }
                    Optionally {
                        EnumQueryParser(Metadata.self, key: "metadata")
                    }
                }
                .throwIfNotFullyParsed()
            
            let values = MapComponentsToValues(parsedLink.components)
            let pathPack = values.0
            self.navigationPath = navigationPath
                .removingAllValues()
                .appendingNonOptional(pack: pathPack.value)
            self.metadata = values.1
        } catch {
             // ...
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            // ...
            .navigationDestination(for: TabPage.self) { tabPage in
                TabPageView(tabPage)
            }
        }
        .onOpenURL { url in 
            guard let link = DeepLink.detectLinkusingBundleID(url: url) else { return }
            parse(link: link)
        }
    }
}

struct TabPageView {
    let tabPage: TabPage

    var body: some View {
        // ...
        .navigationDestination(for: SubPage.self) { subPage in 
            SubPageView(subPage)
        }
    }
}
```