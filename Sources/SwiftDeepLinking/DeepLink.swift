//
//  DeepLink.swift
// SwiftDeepLinking
//
//  Created by Annalise Mariottini on 11/29/24.
//

import Foundation

/// Represents a deep link to be parsed.
public struct DeepLink: Hashable {

    /// Returns a deep link to parse, detecting whether it's a URL scheme link or universal link by comparing the URL scheme to the main bundle ID.
    /// If the passed URL scheme does not match, then it is assumed to be a universal link.
    /// This function may return `nil` if the link is malformed.
    public static func detectLinkUsingBundleID(url: URL, bundle: Bundle = .main) -> Self? {
        guard let urlScheme = bundle.bundleIdentifier else {
            assertionFailure("Bundle \(bundle) has no identifier")
            return nil
        }
        return detectLink(url: url, urlScheme: urlScheme)
    }

    /// Returns a deep link to parse, detecting whether it's a URL scheme link or universal link by comparing the URL scheme to the expected URL scheme value.
    /// If the passed URL scheme does not match, then it is assumed to be a universal link.
    /// This function may return `nil` if the link is malformed.
    public static func detectLink(url: URL, urlScheme: String) -> Self? {
        if URLComponents(url: url, resolvingAgainstBaseURL: true)?.scheme == urlScheme {
            return urlSchemeLink(url: url)
        } else {
            return universalLink(url: url)
        }
    }

    /// Returns a universal deep link to parse.
    public static func universalLink(url: URL) -> Self? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        let unmatchedPath: [String] = url.pathComponents.reversed()
        let unmatchedQuery = (components.queryItems ?? []).reduce(into: [String: String]()) {
            $0[$1.name] = $1.value
        }
        let state = DeepLinkState(url: url, unmatchedPath: unmatchedPath, unmatchedQuery: unmatchedQuery)
        return self.init(url: url, type: .universal, state: state)
    }

    /// Returns a URL scheme deep link to parse.
    /// This function may return `nil` if the link is malformed.
    public static func urlSchemeLink(url: URL) -> Self? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return nil
        }
        let unmatchedPath: [String] = ([host] + url.pathComponents).reversed()
        let unmatchedQuery = (components.queryItems ?? []).reduce(into: [String: String]()) {
            $0[$1.name] = $1.value
        }
        let state = DeepLinkState(url: url, unmatchedPath: unmatchedPath, unmatchedQuery: unmatchedQuery)
        return self.init(url: url, type: .urlScheme, state: state)
    }

    /// The original deep link URL.
    public let url: URL
    /// The original deep link type.
    public let type: DeepLinkType
    private var state: DeepLinkState
}

extension DeepLink: CustomStringConvertible {
    public var description: String {
        let values: [(key: String, value: String)] = [
            ("url", "\"\(url.description)\""),
            ("type", "\(type)"),
            ("matchedPath", state.matchedPath.description),
            ("unmatchedPath", state.unmatchedPath.description),
            ("matchedQuery", state.matchedQuery.description),
            ("unmatchedQuery", state.unmatchQuery.description),
        ]
        return "\(Self.self)(\(values.map { "\($0.key): \($0.value)" }.joined(separator: ", ")))"
    }
}

public enum DeepLinkType: Hashable {
    /// E.g. `https://www.app.com/path/to/page`
    case universal
    /// E.g. `com.app://path/to/page`
    case urlScheme
}

extension DeepLink {
    /// Returns the next link path component to parse, if any.
    public var nextPath: String? {
        state.unmatchedPath.last
    }
    /// Returns the remainig query to parse, if any.
    public var unmatchedQuery: [String: String]? { // swiftlint:disable:this discouraged_optional_collection
        guard !state.unmatchQuery.isEmpty else {
            return nil
        }
        return state.unmatchQuery
    }
    /// Returns true if all link path components have been parsed.
    public var fullyParsed: Bool {
        state.fullyParsed
    }
}

extension DeepLink {
    /// Consumes the next path component if the passed closure returns some value, `nil` otherwise.
    public mutating func consumeNextPath<T: Hashable>(if transformPath: (String) -> T?) -> T? {
        guard let nextPath, let transformed = transformPath(nextPath) else {
            return nil
        }
        popUnmatchedPath()
        pushMatched(nextPath: nextPath)
        return transformed
    }

    /// Consumes the query item if the passed closure returns some value, `nil` otherwise.
    public mutating func consumeQuery<T: Hashable>(if transformQuery: ((key: String, value: String)) -> T?) -> T? {
        guard let unmatchedQuery else { return nil }
        for query in unmatchedQuery {
            if let transformed = transformQuery(query) {
                removeUnmatched(query: query.key)
                addMatched(query: query.key, value: query.value)
                return transformed
            }
        }
        return nil
    }
}

extension DeepLink {
    mutating func filterLeadingSlash() {
        state.filterLeadingSlash()
    }

    mutating func filterEmptyPath() {
        state.filterEmptyPath()
    }

    @discardableResult
    mutating func popUnmatchedPath() -> String? {
        state.unmatchedPath.popLast()
    }

    mutating func pushMatched(nextPath: String) {
        state.matchedPath.append(nextPath)
    }

    @discardableResult
    mutating func removeUnmatched(query key: String) -> String? {
        state.unmatchQuery.removeValue(forKey: key)
    }

    mutating func addMatched(query key: String, value: String) {
        state.matchedQuery[key] = value
    }
}

struct DeepLinkState: Hashable {
    init(url: URL, unmatchedPath: [String], unmatchedQuery: [String: String]) {
        self.url = url
        self.unmatchedPath = unmatchedPath
        self.unmatchQuery = unmatchedQuery
    }
    /// The full deep link URL.
    let url: URL
    /// The URL path that's left to match (reversed order).
    var unmatchedPath: [String]
    /// The URL path that's been matched so far.
    var matchedPath: [String] = []
    /// The URL query that's left to match.
    var unmatchQuery: [String: String]
    /// The URL query that's been matched so far.
    var matchedQuery: [String: String] = [:]

    /// Returns true when the link is fully parsed.
    /// Returns false when the link still has unparsed path or query values.
    var fullyParsed: Bool {
        unmatchedPath.isEmpty && unmatchQuery.isEmpty
    }

    mutating func filterLeadingSlash() {
        self.unmatchedPath = self.unmatchedPath.filter { $0 != "/" }
    }

    mutating func filterEmptyPath() {
        self.unmatchedPath = self.unmatchedPath.filter { !$0.isEmpty }
    }
}
