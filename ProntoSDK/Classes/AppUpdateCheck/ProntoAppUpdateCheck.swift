//
//  ProntoAppUpdateCheck.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 12/02/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation
import UIKit

/// Delegate protocol to receive update
public protocol ProntoAppUpdateCheckDelegate: class {
    func prontoAppUpdateCheck(_ updateCheck: ProntoAppUpdateCheck, newVersion: AppVersion)
}

/// The class to use for app update checks
///
/// **Example**
///
/// ```
/// ProntoSDK.configure(config)
///
/// let updateChecker = ProntoAppUpdateCheck(delegate: self)
/// updateChecker.check()
///
/// // ...
///
/// func prontoAppUpdateCheck(_ updateCheck: ProntoAppUpdateCheck, newVersion: AppVersion) {
///     // Present a UIAlertController (or something) in order to inform the user that a new app version is available
/// }
///
/// ```
public class ProntoAppUpdateCheck: PluginBase {
    /// Weak reference to the ProntoAppUpdateCheckDelegate
    public weak var delegate: ProntoAppUpdateCheckDelegate?

    private var _isChecking = false

    /// Should the SDK automatically check for a new version when the app goes into the foreground
    public var shouldCheckOnAppLaunch = true {
        didSet {
            _updateNotificationCenter()
        }
    }

    /// Creates a new `ProntoAppUpdateCheck` instance
    ///
    /// - parameters:
    ///   - delegate: `ProntoAppUpdateCheckDelegate`
    ///   - checkOnAppLaunch: `Bool` Should this automatically be checked when the app is started (aka -> active)
    public init(delegate: ProntoAppUpdateCheckDelegate? = nil, checkOnAppLaunch: Bool = true) {
        self.delegate = delegate
        self.shouldCheckOnAppLaunch = checkOnAppLaunch
        _updateNotificationCenter()
    }

    public func configure() {

    }

    public var requiredPlugins: [ProntoPlugin] {
        return [ .updateChecker ]
    }

    private func _updateNotificationCenter() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        if shouldCheckOnAppLaunch {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(check),
                                                   name: UIApplication.didBecomeActiveNotification,
                                                   object: nil)
        }
    }

    /// Check for new app versions.
    /// Results will be published through `ProntoAppUpdateCheckDelegate` methods
    @objc
    public func check() {
        if _isChecking {
            ProntoLogger.warning("Already checking for new app versions")
            return
        }
        _isChecking = true
        ProntoLogger.info("Checking new app version...")
        ProntoAPIClient.default.appUpdateChecker.check().then { appVersion in
            self.delegate?.prontoAppUpdateCheck(self, newVersion: appVersion)
        }.always {
            self._isChecking = false
        }
    }
}
