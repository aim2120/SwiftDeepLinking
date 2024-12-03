//
//  OptionallyParserTests.swift
//  SwiftDeepLinkingExample
//
//  Created by Annalise Mariottini on 12/3/24.
//

import Foundation
import Testing

import SwiftParameterPackExtras
import SwiftDeepLinking

struct OptionallyParserTests {
    private let baseURL = URL(string: "https://www.app.com")!

    @Test(arguments: [
        ("abc", "abc"),
        ("ABC", nil),
    ])
    func testOptionallyParser_singleWrapped(addedPath: String, expectedValue: Substring?) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Optionally {
                    RegexPathParser(/[a-z]+/)
                }
            }

        if let expectedValue {
            #expect(parsedLink.fullyParsed)
            #expect(parsedLink.components.value == expectedValue)
        } else {
            let expectedParsedLink = link.parseLeadingSlash()
            #expect(throws: ParsingError.notFullyParsed(link: expectedParsedLink)) {
                try parsedLink.throwIfNotFullyParsed()
            }
            #expect(parsedLink.components.value == nil)
        }
    }

    private static let testOptionallyParser_multipleWrapped_Arguments: [(String, (Substring, Substring)?)] = [
        ("abc/012", ("abc", "012")),
        ("abc", nil),
        ("012", nil),
        ("abc/def", nil),
        ("012/345", nil),
    ]
    @Test(arguments: Self.testOptionallyParser_multipleWrapped_Arguments)
    func testOptionallyParser_multipleWrapped(addedPath: String, expectedValue: (Substring, Substring)?) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Optionally {
                    Parsers {
                        RegexPathParser(/[a-z]+/)
                        RegexPathParser(/[0-9]+/)
                    }
                }
            }

        if let expectedValue {
            #expect(parsedLink.fullyParsed)
            let actualValue = try #require(parsedLink.components.value)
            #expect(actualValue == HashablePack(expectedValue))
        } else {
            let expectedParsedLink = link.parseLeadingSlash()
            #expect(throws: ParsingError.notFullyParsed(link: expectedParsedLink)) {
                try parsedLink.throwIfNotFullyParsed()
            }
            #expect(parsedLink.components.value == nil)
        }
    }
}
