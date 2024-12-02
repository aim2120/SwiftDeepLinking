//
//  ManyParser.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 11/30/24.
//

public struct ManyParser<P: DeepLinkParser>: DeepLinkParser {
    public typealias ParsedComponent = [P.ParsedComponent]

    public init(
        _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
        @DeepLinkParserBuilder parser: @escaping () -> P
    ) {
        self.parser = parser()
    }

    let parser: P

    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        var components: [DeepLinkComponent<P.ParsedComponent>] = []
        while !link.fullyParsed {
            let before = link
            if let component = parser.parse(link: &link) {
                components.append(component)
            }
            let after = link
            if before == after { break }
        }
        if !components.isEmpty {
            return DeepLinkComponent(components.map(\.value))
        }
        return nil
    }
}

public typealias Many = ManyParser
