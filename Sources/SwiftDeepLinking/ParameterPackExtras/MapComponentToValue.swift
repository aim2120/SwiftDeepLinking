//
//  MapComponentToValue.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/2/24.
//

public func MapComponentsToValues<each V: Hashable>(_ value: repeat DeepLinkComponent<each V>) -> (repeat each V) {
    (repeat (each value).value)
}

public func MapComponentsToValues<each V: Hashable>(_ value: (repeat DeepLinkComponent<each V>)) -> (repeat each V) {
    (repeat (each value).value)
}
