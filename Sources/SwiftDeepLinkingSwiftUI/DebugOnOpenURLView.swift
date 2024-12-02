//
//  DebugOnOpenURL.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/29/24.
//

#if canImport(SwiftUI)
import SwiftUI
import SwiftDeepLinking

struct DebugOnOpenURLView<Content: View>: View {
    init(baseURL: String, openURL: @escaping (URL) -> Void, content: Content) {
        self.openURL = openURL
        self.content = content
        self.urlString = baseURL
    }

    private let openURL: (URL) -> Void
    private let content: Content
    @State private var urlString: String

    var body: some View {
        VStack {
            TextField("URL to debug", text: $urlString)
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
                .padding(3)
                .autocorrectionDisabled()
                .onSubmit {
                    guard let url = URL(string: urlString) else { return }
                    openURL(url)
                }
            content
        }
    }
}

struct DebugOnOpenURLViewModifier: ViewModifier {
    let baseURL: String
    let openURL: (URL) -> Void

    func body(content: Content) -> some View {
        DebugOnOpenURLView(baseURL: baseURL, openURL: openURL, content: content)
    }
}

extension View {
    /// Adds a text input bar to debug deep link parsing for your app.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL of your deep link to populate the text field with. Defaults to an empty string.
    ///   - openURL: A function that's called with the URL from the text field.
    /// This should mimic the functionality that you would put in `View.onOpenURL`.
    @available(*, deprecated, message: "This API is for debugging purposes only. It should not be shipped in your final app.")
    public func debugOnOpenURL(baseURL: String = "", openURL: @escaping (URL) -> Void) -> some View {
        modifier(DebugOnOpenURLViewModifier(baseURL: baseURL, openURL: openURL))
    }
}
#endif
