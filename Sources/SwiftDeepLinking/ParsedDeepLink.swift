//
//  ParsedDeepLink.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 12/1/24.
//

import SwiftParameterPackExtras

public struct ParsedDeepLink<each C: Hashable> {
    init(deepLink: DeepLink, components: (repeat DeepLinkComponent<each C>)) {
        self.deepLink = deepLink
        self.components = components
    }
    public let deepLink: DeepLink
    public let components: (repeat DeepLinkComponent<each C>)

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
    public func throwIfNotFullyParsed() throws -> Self {
        try deepLink.throwIfNotFullyParsed()
        return self
    }
}
