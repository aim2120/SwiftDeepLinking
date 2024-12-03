//
//  ParsedDeepLink.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/1/24.
//

import SwiftParameterPackExtras

/// Represents a parsed deep link (returned by ``DeepLink/parse(using:)-9ziwf``).
/// This parsed link contains the components parsed by each of the deep link parsers, as well as the mutated deep link.
///
/// The components contained in this type will correspond to the positions of the deep link parsers used to parse the link.
/// E.g. if you parse with `n` parsers, then the components will be an `n`-tuple.
/// The order of the parsed components also corresponds to order of the parsers (e.g. parser at position `i` will correspond to component at position `i`).
///
/// There is no guarantee that the deep link returned is fully parsed.
/// You can use ``ParsedDeepLink/throwIfNotFullyParsed()`` if you would like to throw an error if the deep link isn't fully parsed.
public struct ParsedDeepLink<each C: Hashable> {
    init(deepLink: DeepLink, components: (repeat DeepLinkComponent<each C>)) {
        self.deepLink = deepLink
        self.components = components
    }
    /// The parsed deep link (may not be fully parsed).
    public let deepLink: DeepLink
    /// The parsed components.
    public let components: (repeat DeepLinkComponent<each C>)

    /// Corresponds to the deep link's ``DeepLink/fullyParsed`` value.
    public var fullyParsed: Bool {
        deepLink.fullyParsed
    }
}

extension ParsedDeepLink: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.deepLink == rhs.deepLink
        && EquatablePack(repeat each lhs.components) == EquatablePack(repeat each rhs.components)
    }
}
extension ParsedDeepLink: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(deepLink)
        repeat hasher.combine(each components)
    }
}

extension ParsedDeepLink {
    /// Throws a ``ParsingError/notFullyParsed(link:)`` error if the deep link is not fully parsed.
    public func throwIfNotFullyParsed() throws -> Self {
        try deepLink.throwIfNotFullyParsed()
        return self
    }
}
