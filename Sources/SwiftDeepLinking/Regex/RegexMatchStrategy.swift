//
//  RegexMatchStrategy.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/30/24.
//

/// The match strategy to use for the regex.
public enum RegexMatchStrategy {
    /// Corresponds to `Regex.wholeMatch`.
    case wholeMatch
    /// Corresponds to `Regex.firstMatch`.
    case firstMatch
    /// Corresponds to `Regex.prefixMatch`.
    case prefixMatch
}

extension Regex {
    func match(in string: String, strategy: RegexMatchStrategy) throws -> Self.Match? {
        switch strategy {
        case .wholeMatch:
            return try wholeMatch(in: string)
        case .firstMatch:
            return try firstMatch(in: string)
        case .prefixMatch:
            return try prefixMatch(in: string)
        }
    }
}
