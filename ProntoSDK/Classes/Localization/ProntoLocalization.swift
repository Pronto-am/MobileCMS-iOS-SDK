//
//  ProntoLocalization.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 23/05/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation
import Promises
import SwiftyJSON

/// Helper class to handle all the localization logic
open class ProntoLocalization: PluginBase {

    private var translations: [String: Text] = [:]
    
    var requiredPlugins: [ProntoPlugin] {
        return [ .localization ]
    }
    
    private weak var apiClient: ProntoAPIClient! = ProntoAPIClient.default

    /// Default constructor
    public init() {
        checkPlugin()
    }

    convenience init(apiClient: ProntoAPIClient) {
        self.init()
        self.apiClient = apiClient
    }

    func configure() {
    }

    /// Sets the default values
    ///
    /// - Parameters:
    ///   - defaults: `[String: [String: String]]`
    ///
    /// **Example defaults**:
    /// ```
    /// [
    ///    "welcome_user": [ "nl": "Welkom", "en": "Welcome" ],
    ///    "next": [ "nl": "Volgende", "en": "Next" ]
    /// ]
    /// ```
    public func setDefaults(_ defaults: [String: [String: String]]) {
        _convertTranslation(defaults)
    }

    /// Reloads the translations
    ///
    /// - returns: `Promise<Void>`
    @discardableResult
    public func fetch() -> Promise<Void> {
        return apiClient.localization.fetch().then { dictionary in
            self._convertTranslation(dictionary)
            return Promise(())
        }
    }

    private func _convertTranslation(_ dictionary: [String: [String: String]]) {
        for (key, value) in dictionary {
            do {
                translations[key] = try JSON(value).map(to: Text.self)
            } catch { }
        }
    }

    /// Gets a translation for a specific key
    ///
    /// - Parameters:
    ///   - key: `String` (e.g. "welcome_user")
    ///   - locale: `Locale` (optonal), else uses current locale
    ///
    /// - Returns: `String?`
    public func get(for key: String, locale: Locale = Locale.current) -> String? {
        guard let text = translations[key] else {
            return nil
        }
        return text.string(for: locale)
    }
}
