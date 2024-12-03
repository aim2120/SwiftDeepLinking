//
//  OptionallyParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/1/24.
//

/// A parser that indicates that some other parser may be an optional part of the parsing strategy.
///
/// This type is particularly useful for paths or query items that may either be present or excluded.
/// If the inner parser is able to parse the link, the it will output the parsed component value.
/// If the inner parser is unable to parse the link, then this parser will output a `nil` component.
///
/// For example, this path requires that `PageA` and `QueryA` be present in the path, but not `PageB` or `QueryB`.
/// ```swift
/// link
/// .parseLeadingSlash()
/// .parse {
///     EnumPathParser(PageA.self)
///     Optionally { EnumPathParser(PageB.self) }
///     EnumQueryParser(QueryA.self, key: "queryA")
///     Optionally { EnumQueryParser(QueryB.self, key: "queryB") }
/// }
/// ```
/// This will successfully parse:
/// - `/<PageA>?queryA=<QueryA>`
/// - `/<PageA>?queryA=<QueryA>&queryB=<QueryB>`
/// - `/<PageA>/<PageB>?query_a=<query_a>`
/// - `/<PageA>/<PageB>?queryA=<QueryA>&queryB=<QueryB>`
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
