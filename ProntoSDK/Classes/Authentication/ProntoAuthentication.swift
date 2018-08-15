//
//  ProntoAuthentication.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 28/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Promises
import KeychainAccess
import SwiftyJSON
import Cobalt

/// Helper class for all authentication related functions
public class ProntoAuthentication: PluginBase {
    fileprivate enum Constants {
        static let userIDKey = "userIDKey"
    }
    var requiredPlugins: [ProntoPlugin] {
        return [ .authentication ]
    }

    private weak var apiClient: ProntoAPIClient!

    /// Default contructor
    public convenience init() {
        self.init(apiClient: ProntoAPIClient.default)
    }

    init(apiClient: ProntoAPIClient) {
        self.apiClient = apiClient
        checkPlugin()
    }

    func configure() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_clear),
                                               name: ProntoSDK.Constant.clearNotificationName,
                                               object: nil)

        ApplicationWatcher.shared.add(plugin: .authentication) { apiClient in
            guard let userID = ProntoSDK.keychain[ProntoAuthentication.Constants.userIDKey] else {
                return
            }
            let parameters = [
                "userID": userID
            ]
            
            try apiClient.firebaseLog.add(type: .signInUser, parameters)
        }
    }

    @objc
    private func _clear() {
        do {
            try ProntoSDK.keychain.remove(Constants.userIDKey)
        } catch { }
        apiClient.client.clearAccessToken()
    }

    /// Login for a specific username (email) and password
    ///
    /// - Parameters:
    ///   - email: `String` the email address
    ///   - password: `String` the password
    ///
    /// - Returns: `Promise<User>`
    public func login(email: String, password: String) -> Promise<User> {
        if !email.isValidEmail {
            return Promise(ProntoError.invalidEmailAddress)
        }
        return apiClient.client.login(username: email, password: password)
        .then { () -> Promise<User> in
            ProntoLogger.success("Succesfully logged in!")
            return self.apiClient.user.profile()
        }.then { user -> Promise<User> in
            ProntoSDK.keychain[Constants.userIDKey] = user.id
            return Promise(user)
        }
    }

    /// Registers a new user.
    ///
    /// After the registration, the user needs to login manually.
    ///
    /// - Parameters:
    ///   - user: `User` the user
    ///   - password: `String` the password
    ///
    /// - Returns: `Promise<User>`
    public func register(user: User, password: String) -> Promise<User> {
        if !user.email.isValidEmail {
            return Promise(ProntoError.invalidEmailAddress)
        }
        return apiClient.user.register(user, password: password)
    }

    /// Unregisters a specific user
    ///
    /// - Parameters:
    ///   - user: `User` the user
    public func unregister(user: User) -> Promise<Void> {
        return apiClient.user.unregister(user).then {
            self.clear()
        }
    }

    /// Logs out the currently logged in user
    public func clear() {
        ProntoLogger.debug("Cleared access-token.")
        _clear()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
