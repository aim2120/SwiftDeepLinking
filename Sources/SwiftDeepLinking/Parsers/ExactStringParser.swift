//
//  ExactStringParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/1/24.
//

/// A deep link parser that parses an exact string.
public struct ExactStringParser<ParsedComponent: Hashable>: DeepLinkParser {
    /// Creates a new exact string parser that transforms to some parsed component value.
    public init(_ exactString: String, transform: @escaping (String) -> ParsedComponent) {
        self.exactString = exactString
        self.transform = transform
    }

    let exactString: String
    let transform: (String) -> ParsedComponent

    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        if let exactString = link.consumeNextPath(if: { next in
            next == exactString ? exactString : nil
        }) {
            return DeepLinkComponent(transform(exactString))
        }
        return nil
    }
}

extension ExactStringParser where ParsedComponent == String {
    /// Creates a new string parser that outputs a string component.
    public init(_ exactString: String) {
        self.init(exactString, transform: { $0 })
    }
}

public typealias Exactly = ExactStringParser
