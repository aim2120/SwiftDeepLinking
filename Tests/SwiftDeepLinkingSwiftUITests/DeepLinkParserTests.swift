//
//  DeepLinkParserTests.swift
//  SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/24/24.
//

#if canImport(SwiftUI)
import SwiftUI
import Foundation
import Testing

import SwiftDeepLinking
import SwiftDeepLinkingSwiftUI

struct DeepLinkParserTests {

    // MARK: Helpers

    private let baseURL = URL(string: "https://www.app.com")!

    enum PageA: String, Hashable, CaseIterable, Codable {
        case p1
        case p2
        case p3
    }

    enum PageB: String, Hashable, CaseIterable, Codable {
        case p1
        case p2
        case p3
    }

    // MARK: Success

    @Test(arguments: PageA.allCases)
    func testNavigationPathParserHandler_singleParser_success(page: PageA) throws {
        let url = baseURL.appending(path: page.rawValue)
        let link = try #require(DeepLink.universalLink(url: url))

        var actualPath = NavigationPath()

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                EnumPathParser(PageA.self)
            }

        actualPath.append(pack: parsedLink.components)

        #expect(parsedLink.deepLink.fullyParsed)
        var expectedPath = NavigationPath()
        expectedPath.append(DeepLinkComponent(page))
        let codableActualPath = try #require(actualPath.codable)
        let codableExpectedPath = try #require(expectedPath.codable)
        #expect(codableActualPath == codableExpectedPath)
    }

    @Test(arguments: combine(PageA.allCases, PageB.allCases))
    func testNavigationPathParserHandler_singleParser_success(pageA: PageA, pageB: PageB) throws {
        let url = baseURL
            .appending(path: pageA.rawValue)
            .appending(path: pageB.rawValue)
        let link = try #require(DeepLink.universalLink(url: url))

        var actualPath = NavigationPath()

        let parsedLink = try link
            .parseLeadingSlash()
            .parse {
                EnumPathParser(PageA.self)
                EnumPathParser(PageB.self)
            }

        actualPath.append(pack: parsedLink.components)

        #expect(parsedLink.deepLink.fullyParsed)
        var expectedPath = NavigationPath()
        expectedPath.append(DeepLinkComponent(pageA))
        expectedPath.append(DeepLinkComponent(pageB))
        let codableActualPath = try #require(actualPath.codable)
        let codableExpectedPath = try #require(expectedPath.codable)
        #expect(codableActualPath == codableExpectedPath)
    }
}

private func combine<S1: Sequence, S2: Sequence>(_ s1: S1, _ s2: S2) -> Array<(S1.Element, S2.Element)> {
    var output: [(S1.Element, S2.Element)] = []
    for es1 in s1 {
        for es2 in s2 {
            output.append((es1, es2))
        }
    }
    return output
}
#endif
