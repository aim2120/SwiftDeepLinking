//
//  ManyParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/30/24.
//

/// A parser that iterates over some other parser.
///
/// When the inner parser successfully parses the deep link, this parser outputs an array of its components.
/// This parser will continue iterating until the deep link is fully parsed or the inner parser is no longer consuming elements from the deep link.
///
/// For example, the  following parser will continue consuming path components that match the regex `/[a-z]+/` until unable to consume any more.
/// ```swift
/// link
/// .parseLeadingSlash()
/// .parse {
///     Many {
///         RegexPathParser(/[a-z]+/)
///     }
/// }
/// ```
/// If we provide a URL with path `/foo/bar/123/baz`, the parser will consume `/foo/bar` and output the component `["foo", "bar"]`.
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
