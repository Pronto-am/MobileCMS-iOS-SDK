//
//  ProntoSDK.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import KeychainAccess
import Logging

let ProntoLogger: Logger? = ProntoSDK.config.logger // swiftlint:disable:this identifier_name

/// The main class, for setting up the pronto SDK
///
/// **Example:**
/// ```
/// let config = ProntoConfig()
/// config.clientID = "client_id"
/// config.clientSecret = "client_secret"
/// config.encryptionKey = "encryption_key"
/// config.plugins = [ .notifications, .authentication, .updateChecker ]
/// ProntoSDK.configure(config)
/// ```
public class ProntoSDK {
    struct Constant {
        static let clearNotificationName = Notification.Name("__prontoClearNotification")
    }

    static var config: ProntoConfig!

    /// Run this command to configure the iOS project with a specific configuration
    ///
    /// Do this in your app delegate's launch method
    ///
    /// - Parameters:
    ///   - config: `ProntoConfig`
    public static func configure(_ config: ProntoConfig) {
        guard self.config == nil else {
            fatalError("Already called `configure(_:)`")
        }
        self.config = config
        if config.encryptionKey == nil {
            fatalError("ProntoConfig.encryptionKey cannot be `nil`")
        }
        ProntoAPIClient.default.configure()
        ApplicationWatcher.shared.configure()
    }

    /// Call this to reset all the currently active plugins
    public static func reset() {
        NotificationCenter.default.post(name: Constant.clearNotificationName, object: nil)
        KeychainHelper.removeAll()
    }
}
