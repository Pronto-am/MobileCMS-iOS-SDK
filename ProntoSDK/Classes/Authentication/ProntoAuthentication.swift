//
//  ProntoAuthentication.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 28/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import KeychainAccess
import SwiftyJSON
import Cobalt

/// Helper class for all authentication related functions
public class ProntoAuthentication: PluginBase {
    fileprivate enum Constants {
        static let user = "stored_user"
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    var requiredPlugins: [ProntoPlugin] {
        return [ .authentication ]
    }

    private(set) weak var apiClient: ProntoAPIClient!
    
    /// Returns the currently logged in user
    private(set) public var currentUser: User? {
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
        rx.authorizationGrantType
            .observeOn(MainScheduler.asyncInstance)
            .skip(1)
            .subscribe(onNext: { [weak self] grantType in
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
    public func login(email: String, password: String) -> Single<User> {
        if !email.isValidEmail {
            return Single<User>.error(ProntoError.invalidEmailAddress)
        }
        return apiClient.client.login(username: email, password: password).flatMap { [apiClient] _ -> Single<User> in
            guard let apiClient = apiClient else {
                return Single<User>.never()
            }
            ProntoLogger?.info("Succesfully logged in!")
            return apiClient.user.profile()
        }.map { user -> User in
            self.currentUser = user
            return user
        }.catchError { error -> Single<User> in
            if let cobaltError = error as? Cobalt.Error, cobaltError == .invalidGrant {
                throw ProntoError.invalidCredentials
            }
            throw error
        }
    }

    /// Registers a new user.
    ///
    /// After the registration, the user needs to login manually.
    ///
    /// - Warning: The user should have: lastName, firstName and email
    ///
    /// - Parameters:
    ///   - user: `User` the user
    ///   - password: `String` the password
    ///
    /// - Returns: `Promise<User>`
    public func register(user: User, password: String) -> Single<User> {
        return apiClient.user.register(user, password: password)
    }

    /// Unregisters a specific user
    ///
    /// - Parameters:
    ///   - user: `User` the user
    public func unregister(user: User) -> Single<Void> {
        return apiClient.user.unregister(user).map { [weak self] _ in
            self?.clear()
        }
    }

    /// Requests a password forgotten change request
    ///
    /// - Parameters:
    ///  - email: String The email address
    ///
    /// - Returns: `Promise<Void>`
    public func passwordResetRequest(email: String) -> Single<Void> {
        return apiClient.user.passwordResetRequest(email: email)
    }

    // Updates the user's profile
    ///
    /// - Warning: The user should have: lastName, firstName and email
    ///
    /// - Parameters:
    ///   - user: `User` The user
    ///
    /// - Returns: `Promise<User>`
    public func update(user: User) -> Single<User> {
        return apiClient.user.update(user)
    }

    /// Get the user profile of the current access-token
    ///
    /// - Returns: `Promise<User>`
    public func getProfile() -> Single<User> {
        return apiClient.user.profile()
    }

    /// Logs out the currently logged in user
    public func clear() {
        ProntoLogger?.debug("Cleared access-token.")
        _clear()
    }

    /// :nodoc:
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ProntoAuthentication {
    fileprivate func _getCurrentUser() -> User? {
        guard let data = KeychainHelper.data(for: Constants.user) else {
            return nil
        }
        
        do {
            let json = try JSON(data: data)
            return try json.map(to: User.self)
        } catch let error {
            ProntoLogger?.error("Error getting: \(error)")
            return nil
        }
    }
    
    fileprivate func _setCurrentUser(_ newValue: User?) {
        do {
            
            guard let user = newValue else {
                KeychainHelper.remove(for: Constants.user)
                return
            }
            let dictionary = try user.encode()
            let data = try JSON(dictionary).rawData()
            
            KeychainHelper.store(data: data, for: Constants.user)
        } catch let error {
            ProntoLogger?.error("Error setting: \(error)")
        }
    }
}
