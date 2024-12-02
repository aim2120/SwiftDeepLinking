//
//  DeepLink+Throw.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/29/24.
//

import Foundation

extension DeepLink {
    /// Throws an error if the current link is not fully parsed.
    /// This may be called after `parse`, if you want to throw an error when the link isn't fully handled.
    ///
    /// Example
    /// ```
    /// univeralLink.parse(handler: Navig
    /// ```
    public func throwIfNotFullyParsed() throws {
        if !fullyParsed {
            throw ParsingError.notFullyParsed(link: self)
        }
    }
}

