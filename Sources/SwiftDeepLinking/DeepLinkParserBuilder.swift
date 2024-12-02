//
//  DeepLinkParserBuilder.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 11/29/24.
//

/// A result builder for ``DeepLinkParser`` parameter packs.
@resultBuilder public enum DeepLinkParserBuilder {

    // MARK: Parameter Pack

    public static func buildBlock<each P: DeepLinkParser>(_ parsers: repeat each P) -> (repeat each P) {
        (repeat each parsers)
    }

    public static func buildEither<each P: DeepLinkParser>(first parsers: repeat each P) -> (repeat each P) {
        (repeat each parsers)
    }

    public static func buildEither<each P: DeepLinkParser>(second parsers: repeat each P) -> (repeat each P) {
        (repeat each parsers)
    }

    // MARK: Single

    public static func buildBlock<P: DeepLinkParser>(_ parsers: P) -> (P) {
        (parsers)
    }

    public static func buildEither<P: DeepLinkParser>(first parsers: (P)) -> (P) {
        (parsers)
    }

    public static func buildEither<P: DeepLinkParser>(second parsers: (P)) -> (P) {
        (parsers)
    }
}
