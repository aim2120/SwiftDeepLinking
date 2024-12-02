//
//  EnumPathParser.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 11/28/24.
//

// MARK: EnumPathParser

/// A deep link parser that transforms a string path component into a given enum type.
public struct EnumPathParser<EnumType: RawRepresentable & Hashable>: DeepLinkParser {
    /// Creates a new enum parser.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - transform: A function to transform the string path component into the enum type, if possible.
    public init(_ enumType: EnumType.Type = EnumType.self, transform: @escaping (String) -> EnumType.RawValue?) {
        self.transform = transform
    }

    let transform: (String) -> EnumType.RawValue?

    public func parse(link: inout DeepLink) -> DeepLinkComponent<EnumType>? {
        if let enumCase = link.consumeNextPath(if: { next in
            if let rawValue = transform(next) {
                return EnumType.init(rawValue: rawValue)
            }
            return nil
        }) {
            return DeepLinkComponent(enumCase)
        }
        return nil
    }
}

extension EnumPathParser where EnumType.RawValue: StringProtocol {
    /// Creates a new enum parser for enum types represented by a string value.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    public init(_ enumType: EnumType.Type = EnumType.self) {
        self.init(enumType, transform: { .init($0) })
    }
}

// MARK: EnumQueryParser

/// A deep link parser that transforms a string path component into a given enum type.
public struct EnumQueryParser<EnumType: RawRepresentable & Hashable>: DeepLinkParser {
    /// Creates a new enum parser.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - key: A function to match the query key.
    ///   - valueTransform: A function to transform the string path component into the enum type, if possible.
    public init(_ enumType: EnumType.Type = EnumType.self,
                key keyMatch: @escaping (String) -> Bool,
                valueTransform: @escaping (String) -> EnumType.RawValue?) {
        self.keyMatch = keyMatch
        self.valueTransform = valueTransform
    }

    /// Creates a new enum parser.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - key: The query key to match.
    ///   - valueTransform: A function to transform the string path component into the enum type, if possible.
    public init<S: StringProtocol>(_ enumType: EnumType.Type = EnumType.self,
                                   key: S,
                                   valueTransform: @escaping (String) -> EnumType.RawValue?) {
        self.init(enumType, key: { $0 == key }, valueTransform: valueTransform)
    }

    /// Creates a new enum parser.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - key: The query key to match.
    ///   - valueTransform: A function to transform the string path component into the enum type, if possible.
    public init<S: StringProtocol>(_ enumType: EnumType.Type = EnumType.self,
                                   key: Regex<S>,
                                   regexStrategy: RegexMatchStrategy = .wholeMatch,
                                   valueTransform: @escaping (String) -> EnumType.RawValue?) {
        self.init(enumType, key: { (try? key.match(in: $0, strategy: regexStrategy)) != nil }, valueTransform: valueTransform)
    }

    let keyMatch: (String) -> Bool
    let valueTransform: (String) -> EnumType.RawValue?

    public func parse(link: inout DeepLink) -> DeepLinkComponent<EnumType>? {
        if let enumCase = link.consumeQuery(if: { query in
            if keyMatch(query.key), let rawValue = valueTransform(query.value) {
                return EnumType.init(rawValue: rawValue)
            }
            return nil
        }) {
            return DeepLinkComponent(enumCase)
        }
        return nil
    }
}

extension EnumQueryParser where EnumType.RawValue: StringProtocol {
    /// Creates a new enum parser for enum types represented by a string value.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - key: A function to match the query key.
    public init(_ enumType: EnumType.Type = EnumType.self,
                key keyMatch: @escaping (String) -> Bool) {
        self.init(enumType, key: keyMatch, valueTransform: { .init($0) })
    }

    /// Creates a new enum parser for enum types represented by a string value.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - key: The query key to match.
    public init<S: StringProtocol>(_ enumType: EnumType.Type = EnumType.self,
                                   key: S) {
        self.init(enumType, key: { $0 == key }, valueTransform: { .init($0) })
    }

    /// Creates a new enum parser for enum types represented by a string value.
    ///
    /// - Parameters:
    ///   - enumType: The enum type this parser detects in string path components.
    ///   - key: The query key to match.
    public init<S: StringProtocol>(_ enumType: EnumType.Type = EnumType.self,
                                   key: Regex<S>,
                                   regexStrategy: RegexMatchStrategy = .wholeMatch) {
        self.init(enumType, key: { (try? key.match(in: $0, strategy: regexStrategy)) != nil }, valueTransform: { .init($0) })
    }
}
