//
//  OptionallyParser.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 12/1/24.
//

public struct OptionallyParser<P: DeepLinkParser>: DeepLinkParser {
    public typealias ParsedComponent = P.ParsedComponent?

    public init(@DeepLinkParserBuilder parser: () -> P) {
        self.parser = parser()
    }

    let parser: P

    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        if let component = parser.parse(link: &link) {
            return DeepLinkComponent(component.value)
        }
        return DeepLinkComponent(nil)
    }
}

public typealias Optionally = OptionallyParser
