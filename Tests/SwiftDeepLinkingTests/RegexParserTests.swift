//
//  RegexParserTests.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/30/24.
//

import Foundation
import Testing
import RegexBuilder

import SwiftDeepLinking

struct RegexParserTests {
    private let baseURL = URL(string: "https://www.app.com")! // swiftlint:disable:this force_unwrapping

    // MARK: RegexPathParser

    @Test(arguments: [
        ("0123", "0123", RegexParserConfig()),
        ("0123/abc", "0123", RegexParserConfig()),
        ("abc0123abc", "0123", RegexParserConfig(strategy: .firstMatch)),
        ("0123abc", "0123", RegexParserConfig(strategy: .prefixMatch)),
        ("abc", nil, RegexParserConfig()),
    ])
    func testRegexPathParser_withSubstringOutput(addedPath: String, expectedValue: Substring?, config: RegexParserConfig) throws {
        let regex = Regex {
            OneOrMore(.digit)
        }
        let parser = RegexPathParser(regex, config: config)
        let url = baseURL.appending(path: addedPath)
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added path: \(addedPath)
            Config: \(config)
            """)
    }

    @Test(arguments: [
        ("0123", 123, RegexParserConfig()),
        ("0123/abc", 123, RegexParserConfig()),
        ("abc0123abc", 123, RegexParserConfig(strategy: .firstMatch)),
        ("0123abc", 123, RegexParserConfig(strategy: .prefixMatch)),
        ("abc", nil, RegexParserConfig()),
    ])
    func testRegexPathParser_withIntOutput(addedPath: String, expectedValue: Int?, config: RegexParserConfig) throws {
        let regex = Regex {
            OneOrMore(.digit)
        }
        let parser = RegexPathParser(regex, config: config) { Int($0.output) }
        let url = baseURL.appending(path: addedPath)
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added path: \(addedPath)
            Config: \(config)
            """)
    }

    @Test(arguments: [
        ("0123", ["0123"], true),
        ("0123/456", ["0123", "456"], true),
        ("0123/456/789", ["0123", "456", "789"], true),
        ("abc", [], false),
        ("0123/abc/456", ["0123"], false),
        ("0123/456/abc/789", ["0123", "456"], false),
    ])
    func testRegexPathParser_parsingFullLink(addedPath: String, expectedValues: [Substring], fullyParsed: Bool) throws {
        let regex = Regex {
            OneOrMore(.digit)
        }
        let parser = RegexPathParser(regex)
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        let parsedLink = try? link.parse {
            Many {
                parser
            }
        }
        let actualValues = parsedLink?.components.value ?? []

        #expect(actualValues == expectedValues, """
            Added path: \(addedPath)
            """)
        #expect(parsedLink?.fullyParsed ?? false == fullyParsed, """
            Added path: \(addedPath)
            """)
    }

    // MARK: RegexQueryParser

    @Test(arguments: [
        (["expected": "0123"], "0123", RegexParserConfig()),
        (["__unexpected__": "456", "expected": "0123"], "0123", RegexParserConfig()),
        (["__expected__": "abc0123abc"], "0123", RegexParserConfig(strategy: .firstMatch)),
        (["expected__": "0123abc"], "0123", RegexParserConfig(strategy: .prefixMatch)),
        (["__unexpected__": "0123"], nil, RegexParserConfig()),
        (["unexpected": "abc"], nil, RegexParserConfig()),
    ])
    func testRegexQueryParser_withSubstringOutput(addedItems: [String: String],
                                                  expectedValue: String?,
                                                  config: RegexParserConfig) throws {
        let keyRegex = /[a-z]+/
        let valueRegex = Regex {
            OneOrMore(.digit)
        }
        let parser = RegexQueryParser(key: keyRegex, value: valueRegex, config: config)
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        if let expectedValue {
            #expect(parser.parse(link: &link)?.value == Substring(expectedValue), """
                Added items: \(addedItems)
                Config: \(config)
                """)
        } else {
            #expect(parser.parse(link: &link)?.value == nil, """
                Added items: \(addedItems)
                Config: \(config)
                """)
        }
    }

    @Test(arguments: [
        (["expected": "0123"], 123, RegexParserConfig()),
        (["__unexpected__": "456", "expected": "0123"], 123, RegexParserConfig()),
        (["__expected__": "abc0123abc"], 123, RegexParserConfig(strategy: .firstMatch)),
        (["expected__": "0123abc"], 123, RegexParserConfig(strategy: .prefixMatch)),
        (["__unexpected__": "0123"], nil, RegexParserConfig()),
        (["unexpected": "abc"], nil, RegexParserConfig()),
    ])
    func testRegexQueryParser_withIntOutput(addedItems: [String: String],
                                            expectedValue: Int?,
                                            config: RegexParserConfig) throws {
        let keyRegex = /[a-z]+/
        let valueRegex = Regex {
            OneOrMore(.digit)
        }
        let parser = RegexQueryParser(key: keyRegex, value: valueRegex, config: config) { Int($1.output) }
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added items: \(addedItems)
            Config: \(config)
            """)
    }

    static let testRegexQueryParser_parsingFullLink_Arguments: [([String: String], Set<Substring>, Bool)] = [
        (["expected": "0123"], ["0123"], true),
        (["expecteda": "0123", "expectedb": "456"], ["0123", "456"], true),
        (["expecteda": "0123", "expectedb": "456", "expectedc": "789"], ["0123", "456", "789"], true),
        (["__unexpected__": "0123"], [], false),
        (["expected": "0123", "__unexpected__": "456"], ["0123"], false),
        (["expecteda": "0123", "__unexpected__": "456", "expectedc": "789"], ["0123", "789"], false),
        (["expected": "0123", "unexpected": "abc"], ["0123"], false),
        (["expecteda": "0123", "unexpected": "abc", "expectedc": "789"], ["0123", "789"], false),
    ]
    @Test(arguments: Self.testRegexQueryParser_parsingFullLink_Arguments)
    func testRegexQueryParser_parsingFullLink(addedItems: [String: String],
                                              expectedValues: Set<Substring>,
                                              fullyParsed: Bool) throws {
        let keyRegex = /[a-z]+/
        let valueRegex = Regex {
            OneOrMore(.digit)
        }
        let parser = RegexQueryParser(key: keyRegex, value: valueRegex)
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        let link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        let parsedLink = try? link.parse {
            Many {
                parser
            }
        }
        let actualValues = Set(parsedLink?.components.value ?? [])

        #expect(actualValues == expectedValues, """
            Added items: \(addedItems)
            """)
        #expect(parsedLink?.fullyParsed ?? false == fullyParsed, """
            Added items: \(addedItems)
            """)
    }
}
