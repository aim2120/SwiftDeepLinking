//
//  EnumParserTests.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 11/30/24.
//

import Foundation
import Testing

import SwiftDeepLinking

struct EnumParserTests {
    let baseURL = URL(string: "https://www.app.com")!

    // MARK: EnumPathParser

    enum StringEnum: String, Hashable, CaseIterable {
        case s1, s2, s3
    }

    enum IntEnum: Int, Hashable, CaseIterable {
        case i1 = 1, i2, i3
    }

    static let testEnumPathParser_withStringValue_Arguments: [(String, StringEnum?)] = {
        StringEnum.allCases.map { ($0.rawValue, $0) } + [("s4", nil)]
    }()
    @Test(arguments: Self.testEnumPathParser_withStringValue_Arguments)
    func testEnumPathParser_withStringValue(addedPath: String, expectedValue: StringEnum?) throws {
        let parser = EnumPathParser(StringEnum.self)
        let url = baseURL.appending(path: addedPath)
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added path: \(addedPath)
            """)
    }

    static let testEnumPathParser_withIntValue_Arguments: [(String, IntEnum?)] = {
        (IntEnum.allCases.map { ($0.rawValue, $0) } + [(4, nil)])
            .map { (String($0.0), $0.1) }
    }()
    @Test(arguments: Self.testEnumPathParser_withIntValue_Arguments)
    func testEnumPathParser_withIntValue(addedPath: String, expectedValue: IntEnum?) throws {
        let parser = EnumPathParser(IntEnum.self) { Int($0) }
        let url = baseURL.appending(path: addedPath)
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added path: \(addedPath)
            """)
    }

    static let testEnumPathParser_parsingFullLink_Arguments: [(String, [StringEnum], Bool)] = [
        ("s1", [.s1], true),
        ("s1/s2", [.s1, .s2], true),
        ("s1/s2/s3", [.s1, .s2, .s3], true),
        ("s4", [], false),
        ("s1/s4,/s2", [.s1], false),
        ("s1/s2/s4/s3", [.s1, .s2], false),
    ]
    @Test(arguments: Self.testEnumPathParser_parsingFullLink_Arguments)
    func testEnumPathParser_parsingFullLink(addedPath: String,
                                            expectedValues: [StringEnum],
                                            fullyParsed: Bool) throws {
        let parser = EnumPathParser(StringEnum.self)
        let url = baseURL.appending(path: addedPath)
        let link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        let parsedLink = try? link.parse {
            Many {
                parser
            }
        }
        let actualValues: [StringEnum] = parsedLink?.components.value ?? []

        #expect(actualValues == expectedValues, """
            Added path: \(addedPath)
            """)
        #expect(parsedLink?.fullyParsed ?? false == fullyParsed, """
            Added path: \(addedPath)
            """)
    }

    // MARK: EnumQueryParser

    static let testEnumQueryParser_withStringValue_AndKeyClosure_Arguments: [([String: String], StringEnum?)] = {
        StringEnum.allCases.map { (["expected": $0.rawValue], $0) }
        + [(["expected": "s4"], nil)]
        + [(["unexpected": "s1"], nil)]
    }()
    @Test(arguments: Self.testEnumQueryParser_withStringValue_AndKeyClosure_Arguments)
    func testEnumQueryParser_withStringValue_andKeyClosure(addedItems: [String: String], expectedValue: StringEnum?) async throws {
        let parser = EnumQueryParser(StringEnum.self, key: { $0 == "expected" })
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added items: \(addedItems)
            """)
    }

    static let testEnumQueryParser_withIntValue_AndKeyClosure_Arguments: [([String: String], IntEnum?)] = {
        IntEnum.allCases.map { (["expected": String($0.rawValue)], $0) }
        + [(["expected": "4"], nil)]
        + [(["unexpected": "1"], nil)]
    }()
    @Test(arguments: Self.testEnumQueryParser_withIntValue_AndKeyClosure_Arguments)
    func testEnumQueryParser_withIntValue_andKeyClosure(addedItems: [String: String], expectedValue: IntEnum?) async throws {
        let parser = EnumQueryParser(IntEnum.self, key: { $0 == "expected" }, valueTransform: { Int($0) })
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added items: \(addedItems)
            """)
    }

    static let testEnumQueryParser_withStringValue_andKeyString_Arguments: [([String: String], StringEnum?)] = {
        StringEnum.allCases.map { (["expected": $0.rawValue], $0) }
        + [(["expected": "s4"], nil)]
        + [(["unexpected": "s1"], nil)]
    }()
    @Test(arguments: Self.testEnumQueryParser_withStringValue_andKeyString_Arguments)
    func testEnumQueryParser_withStringValue_andKeyString(addedItems: [String: String], expectedValue: StringEnum?) async throws {
        let parser = EnumQueryParser(StringEnum.self, key: "expected")
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added items: \(addedItems)
            """)
    }

    static let testEnumQueryParser_withStringValue_andKeyRegex_Arguments: [([String: String], StringEnum?, RegexMatchStrategy?)] = {
        StringEnum.allCases.map { (["expected": $0.rawValue], $0, nil) }
        + [(["__expected__": "s1"], .s1, .firstMatch)]
        + [(["expected__": "s1"], .s1, .prefixMatch)]
        + [(["unexpected": "s4"], nil, nil)]
        + [(["__unexpected__": "s1"], nil, nil)]
    }()
    @Test(arguments: Self.testEnumQueryParser_withStringValue_andKeyRegex_Arguments)
    func testEnumQueryParser_withStringValue_andKeyRegex(addedItems: [String: String], expectedValue: StringEnum?, regexStrategy: RegexMatchStrategy?) async throws {
        let parser = {
            if let regexStrategy {
                return EnumQueryParser(StringEnum.self, key: /[a-z]+/, regexStrategy: regexStrategy)
            } else {
                return EnumQueryParser(StringEnum.self, key: /[a-z]+/)
            }
        }()
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        var link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        #expect(parser.parse(link: &link)?.value == expectedValue, """
            Added items: \(addedItems)
            """)
    }

    static let testEnumQueryParser_parsingFullLink_Arguments: [([String: String], Set<StringEnum>, Bool)] = [
        (["expected": "s1"], [.s1], true),
        (["expecteda": "s1", "expectedb": "s2"], [.s1, .s2], true),
        (["expecteda": "s1", "expectedb": "s2", "expectedc": "s3"], [.s1, .s2, .s3], true),
        (["__unexpected__": "s1"], [], false),
        (["expected": "s1", "__unexpected__": "s2"], [.s1], false),
        (["expecteda": "s1", "__unexpected__": "s2", "expectedc": "s3"], [.s1, .s3], false),
        (["expected": "s1", "unexpected": "s4"], [.s1], false),
        (["expecteda": "s1", "unexpected": "s4", "expectedc": "s3"], [.s1, .s3], false),
    ]
    @Test(arguments: Self.testEnumQueryParser_parsingFullLink_Arguments)
    func testEnumQueryParser_parsingFullLink(addedItems: [String: String],
                                             expectedValues: Set<StringEnum>,
                                             fullyParsed: Bool) throws {
        let parser = EnumQueryParser(StringEnum.self, key: /[a-z]+/)
        let url = baseURL.appending(queryItems: addedItems.map { URLQueryItem(name: $0.key, value: $0.value) })
        let link = try #require(DeepLink.universalLink(url: url)).parseLeadingSlash()

        let parsedLink = try? link.parse {
            Many {
                parser
            }
        }
        let actualValues: Set<StringEnum> = Set(parsedLink?.components.value ?? [])

        #expect(actualValues == expectedValues, """
            Added items: \(addedItems)
            """)
        #expect(parsedLink?.fullyParsed ?? false == fullyParsed, """
            Added items: \(addedItems)
            """)
    }
}
