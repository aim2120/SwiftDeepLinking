//
//  ParsersParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/30/24.
//

import SwiftParameterPackExtras

/// A parser that may contain other parsers, outputting a tuple of their corresponding component values.
///
/// This parser may be useful if you're defining a complex hierarchy of potential deep link paths.
/// For example, if your app has a variety of different deep links that it supports, you can wrap a given path in ``Parsers`` to provide it as a potential path the deep link may contain.
///
/// TODO: Example
public struct ParsersParser<ParsedComponent: Hashable, each P: DeepLinkParser>: DeepLinkParser {
    public init(
        _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
        @DeepLinkParserBuilder parsers: @escaping () -> (repeat (each P)),
        transform: @escaping (repeat DeepLinkComponent<(each P).ParsedComponent>) -> DeepLinkComponent<ParsedComponent>?
    ) {
        self.parsers = (repeat (each parsers()))
        self.transform = transform
    }

    let parsers: (repeat each P)
    let transform: (repeat DeepLinkComponent<(each P).ParsedComponent>) -> DeepLinkComponent<ParsedComponent>?

    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        do {
            // can't use NonOptionalTuple, since we need to short circuit if one fails
            let output = try (repeat (each parsers).parse(link: &link) ?? { throw CancellationError() }())
            return transform(repeat each output)
        } catch {
            return nil
        }
    }
}

extension ParsersParser where ParsedComponent == HashablePack<repeat (each P).ParsedComponent> {
    /// Creates a new parsers container that outputs a `HashablePack` containin the inner parsers' components.
    public init(
        _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
        @DeepLinkParserBuilder parsers: @escaping () -> (repeat (each P))
    ) {
        self.init(parsedComponent, parsers: parsers, transform: { (components: repeat DeepLinkComponent<(each P).ParsedComponent>) -> DeepLinkComponent<ParsedComponent>? in
            DeepLinkComponent(HashablePack(repeat (each components).value))
        })
    }
}

/// Short name for ``ParsersParser``.
public typealias Parsers = ParsersParser
