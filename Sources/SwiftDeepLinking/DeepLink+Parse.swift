//
//  TopLevelParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/28/24.
//

import Foundation

extension DeepLink {
    /// Automatically parses and discards the leading slash of the deep link URL.
    public func parseLeadingSlash() -> Self {
        var copy = self
        copy.filterLeadingSlash()
        return copy
    }
}

// MARK: Parse and Return

extension DeepLink {
    /// Parses the current link using the passed parser.
    ///
    /// - Parameters:
    ///   - parsers: A result builder to specify different parsers that should be used to parse this deep link into components.///
    /// - Returns: A tuple of the parsed components from each parser, along with the parsed link.
    /// - Throws: A ``ParsingError`` if one of the parsers is unable to parse an element.
    @discardableResult
    public func parse<each P: DeepLinkParser>(
        @DeepLinkParserBuilder using parsers: () -> (repeat each P)
    ) throws -> ParsedDeepLink<repeat (each P).ParsedComponent> {
        var copy = self
        let parsers = (repeat (each parsers()))

        func attemptToParse<InnerP: DeepLinkParser>(link: inout DeepLink, with parser: InnerP) throws -> DeepLinkComponent<InnerP.ParsedComponent> {
            guard let component = parser.parse(link: &link) else {
                throw ParsingError.unableToParse(link: link, parser: parser)
            }
            return component
        }

        let components = (repeat try attemptToParse(link: &copy, with: each parsers))
        return ParsedDeepLink(deepLink: copy, components: (repeat each components))
    }

    /// Parses the current link using the passed list of parsers.
    ///
    /// - Parameters:
    ///   - parser: A result builder to specify different parsers that should be used to parse this deep link into components.///
    /// - Returns: The parsed component from the parser, along with the parsed link.
    /// - Throws: A ``ParsingError`` if the parser is unable to parse an element.
    @discardableResult
    public func parse<P: DeepLinkParser>(
        @DeepLinkParserBuilder using parser: () -> P
    ) throws -> ParsedDeepLink<P.ParsedComponent> {
        var copy = self
        let parser = parser()
        guard let components = parser.parse(link: &copy) else {
            throw ParsingError.unableToParse(link: copy, parser: parser)
        }
        return ParsedDeepLink(deepLink: copy, components: components)
    }
}
