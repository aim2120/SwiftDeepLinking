//
//  ParsersParserTests.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/1/24.
//

import Foundation
import Testing

import SwiftParameterPackExtras
import SwiftDeepLinking

struct ParsersParserTests {
    private let baseURL = URL(string: "https://www.app.com")! // swiftlint:disable:this force_unwrapping

    @Test(arguments: [
        ("abc", "abc"),
    ])
    func testParsersParser_single_success(addedPath: String, expectedValue: Substring) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Parsers {
                    RegexPathParser(/[a-z]+/)
                } transform: { $0 }
            }

        #expect(parsedLink.components.value == expectedValue, """
            Added path: \(addedPath)
            """)
    }

    @Test(arguments: [
        ("abc/012", HashablePack("abc", "012")),
    ])
    func testParsersParser_multiple_success(addedPath: String, expectedValue: HashablePack<Substring, Substring>) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Parsers {
                    RegexPathParser(/[a-z]+/)
                    RegexPathParser(/[0-9]+/)
                }
            }

        #expect(parsedLink.components.value == expectedValue, """
            Added path: \(addedPath)
            """)
    }

    @Test(arguments: [
        ("abc/012", [HashablePack("abc", "012")]),
        ("abc/012/def/345", [HashablePack("abc", "012"), HashablePack("def", "345")]),
        ("abc/012/def/345/ghi/678", [HashablePack("abc", "012"), HashablePack("def", "345"), HashablePack("ghi", "678")]),
    ])
    func testParsersParser_multipleWithMany_success(addedPath: String, expectedValues: [HashablePack<Substring, Substring>]) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                Many {
                    Parsers {
                        RegexPathParser(/[a-z]+/)
                        RegexPathParser(/[0-9]+/)
                    }
                }
            }

        #expect(parsedLink.components.value == expectedValues, """
            Added path: \(addedPath)
            """)
    }

    @Test(arguments: [
        ("", 0),
        ("abc", 1),
        ("123", 0),
        ("abc/abc", 1),
        ("123/123", 0),
    ])
    func testParsersParser_failure(addedPath: String, consuming paths: Int) throws {
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url))

        var parsedLink = link.parseLeadingSlash()
        for _ in 0..<paths {
            _ = parsedLink.consumeNextPath(if: { _ in true })
        }

        let parser = Parsers {
            RegexPathParser(/[a-z]+/)
            RegexPathParser(/[0-9]+/)
        }

        #expect(throws: ParsingError.unableToParse(link: parsedLink, parser: parser)) {
            try link
                .parseLeadingSlash()
                .parse {
                    parser
                }
        }
    }
}
