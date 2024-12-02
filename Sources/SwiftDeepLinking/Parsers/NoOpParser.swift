//
//  NoOpParser.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 11/29/24.
//

/// A parser that always returns `nil` when parsing a link.
public struct NoOpParser: DeepLinkParser {
    public func parse(link: inout DeepLink) -> DeepLinkComponent<Void>? {
        nil
    }
    /// A hashable void (to conform to the ``DeepLinkParser`` protocol).
    public struct Void: Hashable, Codable { }
}
