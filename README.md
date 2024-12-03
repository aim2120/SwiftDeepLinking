# SwiftDeepLinking

Implement universal and URL scheme deep links with a composable DSL.

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
                    EnumPathParser(TabPage.self)
                    Optionally {
                        EnumPathParser(SubPage.self)
                    }
                    Optionally {
                        EnumQueryParser(Metadata.self, key: "metadata")
                    }
                }
                .throwIfNotFullyParsed()
            
            let values = MapComponentsToValues(parsedLink.components)
            self.navigationPath = navigationPath.
                .removingAllValues()
                .appending(values.0)
                .appendingIfSome(values.1)
            self.metadata = values.2
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