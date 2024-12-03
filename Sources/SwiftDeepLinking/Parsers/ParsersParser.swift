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
        transform: @escaping (repeat DeepLinkComponent<(each P).ParsedComponent>?) -> DeepLinkComponent<ParsedComponent>?
    ) {
        self.parsers = (repeat (each parsers()))
        self.transform = transform
    }

    let parsers: (repeat each P)
    let transform: (repeat DeepLinkComponent<(each P).ParsedComponent>?) -> DeepLinkComponent<ParsedComponent>?

    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        let output = (repeat (each parsers).parse(link: &link))
        return transform(repeat each output)
    }
}

extension ParsersParser where ParsedComponent == HashablePack<repeat (each P).ParsedComponent> {
    public init(
        _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
        @DeepLinkParserBuilder parsers: @escaping () -> (repeat (each P))
    ) {
        self.init(parsedComponent, parsers: parsers, transform: { (components: repeat DeepLinkComponent<(each P).ParsedComponent>?) -> DeepLinkComponent<ParsedComponent>? in
            guard let nonOptionalComponents = NonOptionalTuple(repeat (each components)?.value) else {
                return nil
            }
            return DeepLinkComponent(HashablePack(repeat each nonOptionalComponents))
        })
    }
}

public typealias Parsers = ParsersParser
