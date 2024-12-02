//
//  ManyParserTests.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 12/1/24.
//

import Foundation
import Testing

import SwiftDeepLinking

struct ManyParserTests {
    let baseURL = URL(string: "https://www.app.com")!

    @Test(arguments: [
        ("abc", ["abc"]),
        ("abc/def", ["abc", "def"]),
        ("abc/def/ghi", ["abc", "def", "ghi"]),
    ])
    func testManyParser_single_success(addedPath: String, expectedValues: [Substring]) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Many {
                    RegexPathParser(/[a-z]+/)
                }
            }
        let actualValues = parsedLink.components.value

        #expect(actualValues == expectedValues, """
            Added path: \(addedPath)
            """)
    }

    @Test(arguments: [
        ("abc/012", ["abc", "012"]),
        ("abc/def/012", ["abc", "def", "012"]),
        ("abc/def/012/345", ["abc", "def", "012", "345"]),
        ("abc/def/ghi/012/345", ["abc", "def", "ghi", "012", "345"]),
        ("abc/def/ghi/012/345/678", ["abc", "def", "ghi", "012", "345", "678"]),
    ])
    func testManyParser_multiple_success(addedPath: String, expectedValues: [Substring]) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Many {
                    RegexPathParser(/[a-z]+/)
                }
                Many {
                    RegexPathParser(/[0-9]+/)
                }
            }
        let actualValues0 = parsedLink.components.0.value
        let actualValues1 = parsedLink.components.1.value

        #expect(actualValues0 + actualValues1 == expectedValues, """
            Added path: \(addedPath)
            """)
    }

    @Test(arguments: [
        "",
        "012",
    ])
    func testManyParser_failure(addedPath: String) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = link.parseLeadingSlash()

        let failingParser = Many {
            RegexPathParser(/[a-z]+/)
        }

        #expect(throws: ParsingError.unableToParse(link: parsedLink, parser: failingParser)) {
            try link
                .parseLeadingSlash()
                .parse {
                    failingParser
                }
        }
    }
}
