//
//  DeepLinkParser.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/24/24.
//

import Foundation

/// A type that parse a deep link to return some parsed component type.
public protocol DeepLinkParser {
    /// The type that's returned after successfully parsing a deep link.
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
    ///     func parse(link: inout DeepLink) -> UniveralLinkComponent<String>? {
    ///         guard let exactString = link.consumeNextPath(if: { $0 == exactString ? $0 : nil }) else {
    ///             return nil
    ///         }
    ///         return DeepLinkComponent(exactString)
    ///     }
    /// }
    /// ```
    func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>?
}
