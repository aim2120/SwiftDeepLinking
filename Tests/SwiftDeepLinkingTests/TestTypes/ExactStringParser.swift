//
//  ExactStringParser.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 12/1/24.
//

import SwiftDeepLinking

struct ExactStringParser: DeepLinkParser {
    let exactString: String
    func parse(link: inout DeepLink) -> DeepLinkComponent<String>? {
        if let exactString = link.consumeNextPath(if: { next in
            next == exactString ? exactString : nil
        }) {
            return DeepLinkComponent(exactString)
        }
        return nil
    }
}
