//
//  URL.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// Text URL class
/// - see: `Text` for more information
public class TextURL: Codable, CustomStringConvertible, ProntoCollectionMapValue {
    private var _text: Text?

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        _text = try Text(from: decoder)
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        try _text?.encode(to: encoder)
    }

    /// Returns the localized url name
    ///
    /// - Parameters:
    ///  - locale: `Locale` (Default = `Locale.current`)
    ///
    /// - Returns: (Optional) `URL`
    public func url(`for` locale: Locale = Locale.current) -> URL? {
        guard let stringValue = _text?.string(for: locale) else {
            return nil
        }
        return URL(string: stringValue)
    }

    /// :nodoc:
    public var description: String {
        return "<TextURL> [ \(String(describing: url())) ]"
    }
}
