//
//  ParsingError.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/2/24.
//

import Foundation

/// Errors that may occur while parsing.
public enum ParsingError: Error, LocalizedError {
    /// Thrown when a link is not fully parsed.
    /// (Usually by ``DeepLink/throwIfNotFullyParsed()`` or ``ParsedDeepLink/throwIfNotFullyParsed()``.)
    case notFullyParsed(link: DeepLink)
    /// Thrown when a parser is unable to parse the deep link.
    case unableToParse(link: DeepLink, parser: any DeepLinkParser)

    public var errorDescription: String? {
        switch self {
        case .notFullyParsed(let link):
            "Not fully parsed: \(link)"
        case .unableToParse(let link, let parser):
            """
            Unable to parse: \(link)
            With parser: \(parser)
            """
        }
    }
}

extension ParsingError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notFullyParsed(let lhsLink), .notFullyParsed(let rhsLink)):
            return lhsLink == rhsLink
        case (.unableToParse(let lhsLink, let lhsParser), .unableToParse(let rhsLink, let rhsParser)):
            return lhsLink == rhsLink
            && lhsParser.isSameType(as: rhsParser)
        default:
            return false
        }
    }
}

extension DeepLinkParser {
    fileprivate func isSameType(as other: any DeepLinkParser) -> Bool {
        other is Self
    }
}
