import SwiftUI
import SwiftDeepLinking
import SwiftDeepLinkingSwiftUI

public struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @State private var colorScheme: ColorScheme?
    @Environment(\.colorScheme) private var systemColorScheme

    private func parse(link: DeepLink) {
        do {
            let parsedLink = try link
                .parseLeadingSlash()
                .parseEmptyPath()
                .parse {
                    Optionally {
                        Parsers {
                            EnumPathParser(PageA1.self)
                            EnumPathParser(PageA2.self)
                            Optionally {
                                RegexPathParser(/[a-zA-Z]+/, transform: { String($0.output) })
                            }
                        }
                    }
                    Optionally {
                        Parsers {
                            EnumPathParser(PageB1.self)
                            EnumPathParser(PageB2.self)
                            Optionally {
                                RegexPathParser(/[a-zA-Z]+/, transform: { String($0.output) })
                            }
                        }
                    }
                    Optionally {
                        EnumQueryParser(RawColorScheme.self, key: "color_scheme")
                    }
                }
                .throwIfNotFullyParsed()

            let values = MapComponentsToValues(parsedLink.components)
            if let firstPack = values.0 {
                navigationPath = navigationPath
                    .removingAll()
                    .appendingNonOptional(pack: firstPack.value)
            } else if let secondPack = values.1 {
                navigationPath = navigationPath
                    .removingAll()
                    .appendingNonOptional(pack: secondPack.value)
            }
            colorScheme = values.2?.colorScheme
        } catch {
            print(error.localizedDescription)
        }
    }

    public var body: some View {
        NavigationView(path: $navigationPath)
            .environment(\.colorScheme, colorScheme ?? systemColorScheme)
            .onOpenURL { url in
                guard let link = DeepLink.detectLinkUsingBundleID(url: url) else { return }
                parse(link: link)
            }
            .debugOnOpenURL(baseURL: "\(Bundle.main.bundleIdentifier!)://") { url in // swiftlint:disable:this force_unwrapping
                guard let link = DeepLink.detectLinkUsingBundleID(url: url) else { return }
                parse(link: link)
            }
    }
}
