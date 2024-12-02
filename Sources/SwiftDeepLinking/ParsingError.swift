//
//  ParsingError.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 12/2/24.
//

import Foundation

/// Errors that may occur while parsing.
public enum ParsingError: Error, LocalizedError {
    /// Thrown when a link is unable to be parsed by any of the provided parsers.
    case notFullyParsed(link: DeepLink)
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
        other as? Self != nil
    }
}