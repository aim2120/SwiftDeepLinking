//
//  ParsersParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/30/24.
//

import SwiftParameterPackExtras

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
