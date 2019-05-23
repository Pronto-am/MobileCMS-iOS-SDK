//
//  Text.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 12/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// A holder for a localized piece of text
public struct Text: Codable, CustomStringConvertible {
    private(set) var localizationDictionary: [String: String] = [:]

    init() {

    }

    /// Get the string for a particular locale
    ///
    /// - Parameters:
    ///   - `locale`: Locale (optional). If empty: ProntoSDK.config.defaultLocale is used
    ///
    /// - Returns: `String`
    public func string(`for` locale: Locale = Locale.current) -> String {
        guard var language = locale.languageCode?.lowercased() else {
            return ""
        }
        if localizationDictionary[language] == nil {
            language = ProntoSDK.config.defaultLocale.languageCode ?? "en"
        }
        if let string = localizationDictionary[language] {
            return string
        }
        ProntoLogger.warning("Cannot find string for language '\(language)'")
        return ""
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        do {
            let dictionary = try decoder.singleValueContainer().decode([String: String].self)
            for (key, value) in dictionary {
                localizationDictionary[key.lowercased()] = value
            }
        } catch {
            let string = try decoder.singleValueContainer().decode(String.self)
            localizationDictionary[ProntoSDK.config.defaultLocale.languageCode ?? "en"] = string
        }
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(localizationDictionary)
    }

    /// :nodoc:
    public var description: String {
        return "<Text> [ \(string()) ] "
    }
}
