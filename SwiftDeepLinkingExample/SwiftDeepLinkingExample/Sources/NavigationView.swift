//
//  NavigationView.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/28/24.
//

import SwiftUI

public struct NavigationView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    @State private var text = ""

    public var body: some View {
        NavigationStack(path: $path) {
            VStack {
                listPage(next: PageA1.self,
                         current: Text("Path 1"),
                         content: { pageSelection(PageA1.self) },
                         destination: { page in
                    listPage(next: PageA2.self,
                             current: Text(page.rawValue),
                             content: { pageSelection(PageA2.self) },
                             destination: { page in
                        listPage(next: String.self,
                                 current: Text(page.rawValue),
                                 content: { textField("Text", text: $text) { path.append(text) } },
                                 destination: { Text($0) })
                    })
                })
                listPage(next: PageB1.self,
                         current: Text("Path 2"),
                         content: { pageSelection(PageB1.self) },
                         destination: { page in
                    listPage(next: PageB2.self,
                             current: Text(page.rawValue),
                             content: { pageSelection(PageB2.self) },
                             destination: { page in
                        listPage(next: String.self,
                                 current: Text(page.rawValue),
                                 content: { textField("Text", text: $text) { path.append(text) } },
                                 destination: { Text($0) })
                    })
                })
            }
        }
    }

    func listPage<
        Current: View,
        Content: View,
        NextPage: Hashable & Codable,
        NextPageDestination: View
    >(
        next: NextPage.Type,
        current: @autoclosure () -> Current,
        content: () -> Content,
        destination: @escaping (NextPage) -> NextPageDestination
    ) -> some View {
        List {
            HStack {
                icon
                current()
            }
            content()
        }.navigationDestination(for: NextPage.self) { page in
            destination(page)
        }
    }

    func textField(_ value: String, text: Binding<String>, onSubmit: @escaping () -> Void) -> some View {
        TextField(value, text: text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(3)
            .onSubmit(onSubmit)
            .onDisappear {
                text.wrappedValue = ""
            }
    }

    func pageSelection<Page: CaseIterable & Hashable & Codable & Identifiable & RawRepresentable>(
        _ next: Page.Type = Page.self
    ) -> some View where Page.RawValue == String, Page.AllCases == [Page] {
        ForEach(Page.allCases) { page in
            Button(page.rawValue) {
                path.append(page)
            }
        }
    }

    var icon: some View {
        switch colorScheme {
        case .dark:
            return Image(systemName: "moon.fill")
        case .light:
            return Image(systemName: "sun.max.fill")
        @unknown default:
            return Image(systemName: "sun.max.fill")
        }
    }
}
