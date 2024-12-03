//
//  MapComponentToValue.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/2/24.
//

/// Maps a tuple of ``DeepLinkComponent`` to their corresponding parsed component value.
public func MapComponentsToValues<each V: Hashable>(_ value: repeat DeepLinkComponent<each V>) -> (repeat each V) {
    (repeat (each value).value)
}

/// Maps a tuple of ``DeepLinkComponent`` to their corresponding parsed component value.
public func MapComponentsToValues<each V: Hashable>(_ value: (repeat DeepLinkComponent<each V>)) -> (repeat each V) {
    (repeat (each value).value)
}
