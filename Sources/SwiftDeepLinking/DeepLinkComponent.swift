//
//  DeepLinkComponent.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/24/24.
//

import Foundation

/// A value type that is returned by a ``DeepLinkParser`` when it successfully parses a path component from a deep link
/// This type contains the ``DeepLinkParser/ParsedComponent`` type as a wrapped value.
public struct DeepLinkComponent<ParsedComponent: Hashable>: Hashable {
    /// Creates a new deep link component, after parsing a value from its string path.
    public init(_ value: ParsedComponent) {
        self.value = value
    }

    /// The value that was parsed from the deep link.
    public let value: ParsedComponent
}
extension DeepLinkComponent: Codable where ParsedComponent: Codable { }
