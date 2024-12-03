//
//  ExactStringParserTests.swift
//  SwiftDeepLinkingExample
//
//  Created by Annalise Mariottini on 12/3/24.
//

import Foundation
import Testing

import SwiftDeepLinking

struct ExactStringParserTests {
    private let baseURL = URL(string: "https://www.app.com")! // swiftlint:disable:this force_unwrapping

    @Test(arguments: [
        (UUID().uuidString),
    ])
    func testExactStringParser_outputtingString(addedPath: String) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Exactly(addedPath)
            }

        #expect(parsedLink.fullyParsed)
        #expect(parsedLink.components.value == addedPath)
    }

    @Test(arguments: [
        (UUID().uuidString),
    ])
    func testExactStringParser_outputtingOtherValue(addedPath: String) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Exactly(addedPath) { Container($0) }
            }

        #expect(parsedLink.fullyParsed)
        #expect(parsedLink.components.value == Container(addedPath))
    }
}

private struct Container: Hashable, Codable {
    init(_ string: String) {
        self.string = string
    }
    let string: String
}
