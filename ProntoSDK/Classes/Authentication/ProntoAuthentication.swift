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
import RxSwift

/// Helper class for all authentication related functions
public class ProntoAuthentication: PluginBase {
    fileprivate enum Constants {
        static let user = "stored_user"
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    var requiredPlugins: [ProntoPlugin] {
        return [ .authentication ]
    }

    private weak var apiClient: ProntoAPIClient!
    
    /// Returns the currently logged in user
    public var currentUser: User? {
        get {
           return _getCurrentUser()
        }
        set {
            _setCurrentUser(newValue)
        }
    }

    /// Default contructor
    public convenience init() {
        self.init(apiClient: ProntoAPIClient.default)
    }

    init(apiClient: ProntoAPIClient) {
        self.apiClient = apiClient
        apiClient.rx.authorizationGrantType.subscribe(onNext: { [weak self] grantType in
            if grantType == nil {
                self?._clear()
            }
        }).disposed(by: disposeBag)
        checkPlugin()
    }

    func configure() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_clear),
                                               name: ProntoSDK.Constant.clearNotificationName,
                                               object: nil)

        ApplicationWatcher.shared.add(plugin: .authentication) { apiClient in
            guard let user = self.currentUser else {
                return
            }
            let parameters = [
                "userID": user.id
            ]
            
            try apiClient.firebaseLog.add(type: .signInUser, parameters)
        }
    }

    @objc
    private func _clear() {
        self.currentUser = nil
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
            self.currentUser = user
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

extension ProntoAuthentication {
    fileprivate func _getCurrentUser() -> User? {
        #if targetEnvironment(simulator)
        guard let data = UserDefaults.standard.data(forKey: Constants.user) else {
            return nil
        }
        #else
        guard let data = ProntoSDK.keychain[data: Constants.user] else {
            return nil
        }
        
        #endif
        do {
            let json = try JSON(data: data)
            return try json.map(to: User.self)
        } catch let error {
            ProntoLogger.error("Error getting: \(error)")
            return nil
        }
    }
    
    fileprivate func _setCurrentUser(_ newValue: User?) {
        do {
            
            guard let user = newValue else {
                #if targetEnvironment(simulator)
                UserDefaults.standard.removeObject(forKey: Constants.user)
                UserDefaults.standard.synchronize()
                #else
                ProntoSDK.keychain[data: Constants.user] = nil
                #endif
                return
            }
            let dictionary = try user.encode()
            let data = try JSON(dictionary).rawData()
            
            #if targetEnvironment(simulator)
            UserDefaults.standard.set(data, forKey: Constants.user)
            UserDefaults.standard.synchronize()
            #else
            ProntoSDK.keychain[data: Constants.user] = data
            #endif
        } catch let error {
            ProntoLogger.error("Error setting: \(error)")
        }
    }
}
