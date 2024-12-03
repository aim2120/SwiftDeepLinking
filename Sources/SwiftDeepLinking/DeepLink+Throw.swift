//
//  DeepLink+Throw.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/29/24.
//

import Foundation

extension DeepLink {
    /// Throws a ``ParsingError/notFullyParsed(link:)`` error if the deep link is not fully parsed.
    public func throwIfNotFullyParsed() throws {
        if !fullyParsed {
            throw ParsingError.notFullyParsed(link: self)
        }
    }
}
