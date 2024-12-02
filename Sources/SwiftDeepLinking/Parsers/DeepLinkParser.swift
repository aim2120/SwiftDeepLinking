//
//  DeepLinkParser.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/24/24.
//

import Foundation

/// A type that parse a deep link, one path component at a time.
public protocol DeepLinkParser {
    associatedtype ParsedComponent: Hashable
    /// Implements parsing of the passed deep link.
    /// If the next link path component can be parsed by this parser, a link component should be returned with a corresponding value.
    ///
    /// Some parsers that are already implemented:
    /// - ``RegexPathParser``
    /// - ``EnumPathParser``
    ///
    /// Here's an example of how this function may be implemented:
    /// ```
    /// struct ExactStringParser: DeepLinkParser {
    ///     let exactString: String
    ///
    ///     func parse(link: DeepLink) -> UniveralLinkComponent<String>? {
    ///         guard let next = link.next else { return nil }
    ///         guard next == exactString else { return nil }
    ///         return DeepLinkComponent(exactString)
    ///     }
    /// }
    /// ```
    func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>?
}
