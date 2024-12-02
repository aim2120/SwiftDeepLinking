//
//  RegexPathParser.swift
//  NavigationExample
//
//  Created by Annalise Mariottini on 11/28/24.
//

// MARK: RegexPathParser

/// A deep link parser that parses some regex into a parsed component output.
public struct RegexPathParser<Output, ParsedComponent: Hashable>: DeepLinkParser {
    /// Creates a new regex parser for the given regex.
    ///
    /// - Parameters:
    ///   - regex: The regex to match.
    ///   - parsedComponent: The parsed component type.
    ///   - transform: A function to transform the regex output into the parsed component type.
    public init(_ regex: Regex<Output>,
                _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
                config: RegexParserConfig = .init(),
                transform: @escaping (Regex<Output>.Match) -> ParsedComponent?) {
        self.regex = regex
        self.config = config
        self.transform = transform
    }

    let regex: Regex<Output>
    let config: RegexParserConfig
    let transform: (Regex<Output>.Match) -> ParsedComponent?
    
    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        if let component = link.consumeNextPath(if: { next in
            if let match = try? regex.match(in: next, strategy: config.strategy) {
                return transform(match)
            }
            return nil
        }) {
            return DeepLinkComponent(component)
        }
        return nil
    }
}

extension RegexPathParser where Output == ParsedComponent {
    /// Creates a new regex parser for the given regex that outputs some parsed component type.
    ///
    /// - Parameters:
    ///   - regex: The regex to match.
    ///   - parsedComponent: The parsed component type.
    public init(_ regex: Regex<Output>,
                _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
                config: RegexParserConfig = .init()) {
        self.init(regex, parsedComponent, config: config, transform: { $0.output })
    }
}

// MARK: RegexQueryParser

public struct RegexQueryParser<KeyOutput, ValueOutput, ParsedComponent: Hashable>: DeepLinkParser {
    /// Creates a new regex parser for the given regex.
    ///
    /// - Parameters:
    ///   - key: The regex to match for the query key.
    ///   - value: The regex to match for the query value.
    ///   - parsedComponent: The parsed component type.
    ///   - transform: A function to transform the regex output into the parsed component type.
    public init(key keyRegex: Regex<KeyOutput>,
                value valueRegex: Regex<ValueOutput>,
                _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
                config: RegexParserConfig = .init(),
                transform: @escaping (Regex<KeyOutput>.Match, Regex<ValueOutput>.Match) -> ParsedComponent?) {
        self.keyRegex = keyRegex
        self.valueRegex = valueRegex
        self.config = config
        self.transform = transform
    }

    let keyRegex: Regex<KeyOutput>
    let valueRegex: Regex<ValueOutput>
    let config: RegexParserConfig
    let transform: (Regex<KeyOutput>.Match, Regex<ValueOutput>.Match) -> ParsedComponent?

    public func parse(link: inout DeepLink) -> DeepLinkComponent<ParsedComponent>? {
        if let component = link.consumeQuery(if: { query in
            if let keyMatch = try? keyRegex.match(in: query.key, strategy: config.strategy),
               let valueMatch = try? valueRegex.match(in: query.value, strategy: config.strategy) {
                return transform(keyMatch, valueMatch)
            }
            return nil
        }) {
            return DeepLinkComponent(component)
        }
        return nil
    }
}

extension RegexQueryParser where ValueOutput == ParsedComponent {
    /// Creates a new regex parser for the given regex that outputs the value regex output.
    ///
    /// - Parameters:
    ///   - key: The regex to match for the query key.
    ///   - value: The regex to match for the query value.
    ///   - parsedComponent: The parsed component type.
    public init(key keyRegex: Regex<KeyOutput>,
                value valueRegex: Regex<ValueOutput>,
                _ parsedComponent: ParsedComponent.Type = ParsedComponent.self,
                config: RegexParserConfig = .init()) {
        self.init(key: keyRegex, value: valueRegex, config: config, transform: { _, v in v.output })
    }
}

// MARK: Config

/// Configuration options for a regex parser.
public struct RegexParserConfig {
    public init(strategy: RegexMatchStrategy = .wholeMatch) {
        self.strategy = strategy
    }
    public let strategy: RegexMatchStrategy
}
