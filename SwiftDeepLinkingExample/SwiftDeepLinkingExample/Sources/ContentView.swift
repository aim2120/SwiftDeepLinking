import SwiftUI
import SwiftDeepLinking
import SwiftDeepLinkingSwiftUI

public struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @State private var color: Color = .white

    private func parse(link: DeepLink) {
        do {
            let parsedLink = try link
                .parseLeadingSlash()
                .parse {
                    RegexPathParser(/[a-zA-Z]+/, transform: { String($0.output) })
                    RegexPathParser(/[0-9]+/, transform: { Int($0.output) })
                    Optionally {
                        EnumPathParser(Page.self)
                    }
                    Optionally {
                        EnumQueryParser<AppColor>(key: "color")
                    }
                }
                .throwIfNotFullyParsed()

            let components = parsedLink.components
            let values = MapComponentsToValues(components)
            self.navigationPath = navigationPath
                .removingAll()
                .appending(values.0)
                .appending(values.1)
                .appendingIfSome(values.2)
            self.color = values.3?.color ?? .primary
        } catch {
            print(error.localizedDescription)
        }
    }

    public var body: some View {
        NavigationView(path: $navigationPath, color: $color)
            .onOpenURL { url in
                guard let link = DeepLink.detectLinkUsingBundleID(url: url) else { return }
                parse(link: link)
            }
            .debugOnOpenURL(baseURL: "\(Bundle.main.bundleIdentifier!)://") { url in
                guard let link = DeepLink.detectLinkUsingBundleID(url: url) else { return }
                parse(link: link)
            }
    }
}
