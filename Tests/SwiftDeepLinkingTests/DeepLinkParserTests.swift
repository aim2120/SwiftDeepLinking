//
//  DeepLinkParserTests.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/24/24.
//

import Foundation
import Testing

import SwiftDeepLinking

struct DeepLinkParserTests {

    // MARK: Helpers

    private let baseURL = URL(string: "https://www.app.com")! // swiftlint:disable:this force_unwrapping
    private let exactString = "hello_world"

    enum StringEnum: String, Hashable, CaseIterable {
        case s1
        case s2
        case s3
    }

    enum IntEnum: Int, Hashable, CaseIterable {
        case i1 = 1
        case i2
        case i3
    }

    enum CodableEnum: String, Hashable, Codable {
        case c1
    }

    private static let letters: [Substring] = ["a", "b", "c"]

    static func combineLetterStringInt() -> [(letter: Substring, string: StringEnum, int: IntEnum)] {
        combine(letters, combine(StringEnum.allCases, IntEnum.allCases))
            .map {
                ($0.0, $0.1.0, $0.1.1)
            }
    }

    // MARK: Success

    @Test func testParseLeadingSlash_success() throws {
        let url = baseURL.appending(path: "")
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = link
            .parseLeadingSlash()

        #expect(parsedLink.fullyParsed)
    }

    @Test(arguments: Self.combineLetterStringInt())
    func testMultipleParsers_success(testCase: (letter: Substring, string: StringEnum, int: IntEnum)) throws {
        let url = baseURL
            .appending(path: testCase.letter)
            .appending(path: testCase.string.rawValue)
            .appending(path: String(testCase.int.rawValue))
            .appending(path: exactString)
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                RegexPathParser(/[a-z]/, Substring.self)
                EnumPathParser(StringEnum.self)
                EnumPathParser(IntEnum.self) { Int($0) }
                ExactStringParser(exactString)
            }

        let parsedLetterComponent = parsedLink.components.0
        let parsedStringEnumComponent = parsedLink.components.1
        let parsedIntEnumComponent = parsedLink.components.2
        let parsedExactStringComponent = parsedLink.components.3

        #expect(parsedLink.fullyParsed)
        #expect(parsedLetterComponent.value == testCase.letter)
        #expect(parsedStringEnumComponent.value.rawValue == testCase.string.rawValue)
        #expect(parsedIntEnumComponent.value.rawValue == testCase.int.rawValue)
        #expect(parsedExactStringComponent.value == exactString)
    }

    // MARK: Failure

    @Test func testParseLeadingSlash_failure() throws {
        let url = baseURL.appending(path: "more")
        let link = try #require(DeepLink.universalLink(url: url))

        let parsedLink = link
            .parseLeadingSlash()

        #expect(throws: ParsingError.notFullyParsed(link: parsedLink)) {
            try parsedLink.throwIfNotFullyParsed()
        }
    }

    @Test(arguments: Self.combineLetterStringInt())
    func testMultipleParsers_failure(testCase: (letter: Substring, string: StringEnum, int: IntEnum)) throws {
        let url = baseURL
            .appending(path: "\(testCase.letter)0")
            .appending(path: "\(testCase.string.rawValue)0")
            .appending(path: "\(testCase.int.rawValue)0")
            .appending(path: "\(exactString)0")
        let link = try #require(DeepLink.universalLink(url: url))

        // replicate the link mutation
        let parsedLink = link.parseLeadingSlash()
        let failingParser = RegexPathParser(/[a-z]/, Substring.self)

        #expect(throws: ParsingError.unableToParse(link: parsedLink, parser: failingParser)) {
            try link
                .parseLeadingSlash()
                .parse {
                    failingParser
                    EnumPathParser(StringEnum.self)
                    EnumPathParser(IntEnum.self) { Int($0) }
                    ExactStringParser(exactString)
                }
        }
    }

    @Test(arguments: Self.combineLetterStringInt())
    func testMultipleParsers_returningComponents_partialSuccess(testCase: (letter: Substring, string: StringEnum, int: IntEnum)) throws {
        let url = baseURL
            .appending(path: testCase.letter)
            .appending(path: String(testCase.string.rawValue))
            .appending(path: "\(testCase.int.rawValue)0")
            .appending(path: "\(exactString)0")
        let link = try #require(DeepLink.universalLink(url: url))

        // replicate the link mutation due to partial parsing
        var parsedLink = link.parseLeadingSlash()
        _ = parsedLink.consumeNextPath(if: { _ in true })
        _ = parsedLink.consumeNextPath(if: { _ in true })

        let failingParser = EnumPathParser(IntEnum.self) { Int($0) }

        #expect(throws: ParsingError.unableToParse(link: parsedLink, parser: failingParser)) {
            try link
                .parseLeadingSlash()
                .parse {
                    RegexPathParser(/[a-z]/, Substring.self)
                    EnumPathParser(StringEnum.self)
                    failingParser
                    ExactStringParser(exactString)
                }
        }
    }
}
