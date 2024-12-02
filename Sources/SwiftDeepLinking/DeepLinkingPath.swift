//
//  DeepLinking.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 12/2/24.
//

import SwiftParameterPackExtras

/// Defines a type that acts as a deep link path for app navigation.
public protocol DeepLinkingPath {
    /// Appends a new codable value to the end of this path.
    mutating func append<V: Hashable & Codable>(_ value: V)
    /// Removes values from the end of this path.
    mutating func removeLast(_ k: Int)
    /// The number of elements in this path.
    var count: Int { get }
}

extension DeepLinkingPath {
    /// Removes all valuess from the current path.
    public mutating func removeAll() {
        self.removeLast(self.count)
    }

    /// Removes all valuess from the current path, returning a new instance.
    public func removingAll() -> Self {
        var copy = self
        copy.removeAll()
        return copy
    }

    /// Appends a new codable value to the end of this path, returning a new instance.
    public func appending<V: Hashable & Codable>(_ value: V) -> Self {
        var copy = self
        copy.append(value)
        return copy
    }

    /// Appends each values of the passed hashable sequence.
    public mutating func append<S: Sequence>(contentsOf sequence: S) where S.Element: Hashable & Codable {
        for el in sequence {
            self.append(el)
        }
    }

    /// Appends each values of the passed hashable sequence, returning a new instance.
    public func appending<S: Sequence>(contentsOf sequence: S) -> Self where S.Element: Hashable & Codable {
        var copy = self
        copy.append(contentsOf: sequence)
        return copy
    }

    /// Appends the value if the condition evaluates as true.
    public mutating func append<V: Hashable & Codable>(_ value: V, if condition: (V) -> Bool) {
        if condition(value) {
            self.append(value)
        }
    }

    /// Appends the value if the condition evaluates as true, returning a new instance.
    public func appending<V: Hashable & Codable>(_ value: V, if condition: (V) -> Bool) -> Self {
        var copy = self
        copy.append(value, if: condition)
        return copy
    }

    /// Appends the optional values if it is some value (not none).
    public mutating func appendIfSome<V: Hashable & Codable>(_ optionalValue: V?) {
        if let optionalValue {
            self.append(optionalValue)
        }
    }

    /// Appends the optional values if it is some value (not none), returning a new instance.
    public func appendingIfSome<V: Hashable & Codable>(_ optionalValue: V?) -> Self {
        var copy = self
        copy.appendIfSome(optionalValue)
        return copy
    }

    /// Appends each of the valuess in the passed parameter pack tuple.
    public mutating func append<each V: Hashable & Codable>(pack: (repeat each V)) {
        repeat append(each pack)
    }

    /// Appends each of the valuess in the passed parameter pack tuple, returning a new instance.
    public func appending<each V: Hashable & Codable>(pack: (repeat each V)) -> Self {
        var copy = self
        copy.append(pack: (repeat each pack))
        return copy
    }

    /// Appends each of the valuess in the passed parameter pack tuple.
    public mutating func appendNonOptional<each V: Hashable & Codable>(pack: (repeat (each V)?)) {
        func appendNonOptional<InnerV: Hashable & Codable>(_ value: InnerV?) {
            if let value {
                self.append(value)
            }
        }
        repeat appendNonOptional(each pack)
    }

    /// Appends each of the valuess in the passed parameter pack tuple, returning a new instance.
    public func appendingNonOptional<each V: Hashable & Codable>(pack: (repeat (each V)?)) -> Self {
        var copy = self
        copy.appendNonOptional(pack: (repeat each pack))
        return copy
    }

    /// Appends each of the valuess in the passed Hashable parameter pack tuple.
    public mutating func append<each V: Hashable & Codable>(pack: HashablePack<repeat each V>) {
        repeat append(each pack.value)
    }

    /// Appends each of the valuess in the passed Hashable parameter pack tuple, returning a new instance.
    public func appending<each V: Hashable & Codable>(pack: HashablePack<repeat each V>) -> Self {
        var copy = self
        copy.append(pack: pack)
        return copy
    }
}
