//
//  NavigationView.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/28/24.
//

import SwiftUI

public struct NavigationView: View {
    @Binding var path: NavigationPath
    @Binding var color: Color
    @State private var letters = ""
    @State private var number = ""

    public var body: some View {
        NavigationStack(path: $path) {
            List {
                TextField("Letters", text: $letters)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(3)
                    .onSubmit {
                        path.append(letters)
                    }
            }
            .foregroundStyle(color)
            .navigationDestination(for: String.self) { letters in
                letterView(letters: letters)
            }
        }
    }

    func letterView(letters: String) -> some View {
        List {
            Text(letters)
            TextField("Number", text: $number)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(3)
                .onSubmit {
                    if let number = Int(self.number) {
                        path.append(number)
                    }
                }
        }
        .foregroundStyle(color)
        .navigationDestination(for: Int.self) { number in
            numberView(number: number)
        }
    }

    func numberView(number: Int) -> some View {
        List {
            Text("\(number)")
            ForEach(Page.allCases, id: \.self) { page in
                HStack {
                    Button("\(page)") {
                        path.append(page)
                    }
                }
            }
        }
        .foregroundStyle(color)
        .navigationDestination(for: Page.self) { page in
            pageView(page: page)
        }
    }

    func pageView(page: Page) -> some View {
        List {
            Text("\(page.rawValue)")
        }
        .foregroundStyle(color)
    }
}
