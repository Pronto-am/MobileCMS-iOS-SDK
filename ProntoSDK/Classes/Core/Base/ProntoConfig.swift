//
//  ProntoConfig.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 29/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Cobalt

/// Configuration class
public class ProntoConfig {

    /// Pronto API client id
    public var clientID: String = ""

    /// Pronto API client secret
    public var clientSecret: String = ""

    /// Fallback language (default: en_US)
    public var defaultLocale: Locale = Locale(identifier: "en_US")

    /// The domain name of the pronto cms (default: pronto.am)
    public var domain: String = "pronto.am"

    /// The domain name of the pronto cms (default: pronto-am.firebaseio.com)
    public var firebaseDomain: String = "pronto-am.firebaseio.com"

    /// Encryption key
    public var encryptionKey: String?

    /// Available plugins
    public var plugins: [ProntoPlugin] = []

    /// API Version (default = v1)
    public var apiVersion: String = "v1"

    /// Application Version (default = V1)
    public var applicationVersion: String = "V1"

    /// The logger
    public var logger: Cobalt.Logger?

    /// :nodoc:
    public init() {

    }

    /// :nodoc:
    public convenience init(_ builder: ((ProntoConfig) -> Void)) {
        self.init()
        builder(self)
    }
}
