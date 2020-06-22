//
//  ProntoAPIClientUserModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 28/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Cobalt
import SwiftyJSON

/// For all (app) user related API calls
class ProntoAPIClientUserModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    /// Get the user profile of the current access-token
    ///
    /// - Returns: `Promise<User>`
    func profile() -> Single<User> {
        let request = Cobalt.Request({
            $0.authentication = .oauth2(.password)
            $0.path = prontoAPIClient.versionPath(for: "/users/app/profile")
        })
        
        return prontoAPIClient.request(request).map { json -> User in
            return try json["data"].map(to: User.self)
        }
    }
    
    private func _checkValid(user: User) -> Single<User>? {
        if user.firstName.isEmpty {
            return Single<User>.error(ProntoError.missingField("firstName"))
            
        } else if user.email.isEmpty {
            return Single<User>.error(ProntoError.missingField("email"))
            
        } else if !user.email.isValidEmail {
            return Single<User>.error(ProntoError.invalidEmailAddress)
        }
        return nil
    }
    
    /// Updates the user's profile
    ///
    /// - Warning: The user should have: lastName, firstName and email
    ///
    /// - Parameters:
    ///   - user: `User` The user
    ///
    /// - Returns: `Promise<User>`
    func update(_ user: User) -> Single<User> {
        if let singleError = _checkValid(user: user) {
            return singleError
        }
        
        do {
            let obj = try user.encode { encoder in
                guard let codingKey = CodingUserInfoKey(rawValue: "context") else {
                    return
                }
                encoder.userInfo = [
                    codingKey: "update_profile"
                ]
            }

            let request = Cobalt.Request({
                $0.authentication = .oauth2(.password)
                $0.path = prontoAPIClient.versionPath(for: "/users/app/profile")
                $0.httpMethod = .put
                $0.parameters = obj
            })

            return prontoAPIClient.request(request).map { json -> User in
                return try json["data"].map(to: User.self)
            }
        } catch let error {
            return Single<User>.error(error)
        }
    }
    
    /// Requests a password forgotten change request
    ///
    /// - Parameters:
    ///  - email: String The email address
    ///
    /// - Returns: `Promise<Void>`
    func passwordResetRequest(email: String) -> Single<Void> {
        let request = Cobalt.Request({
            $0.authentication = .oauth2(.clientCredentials)
            $0.path = prontoAPIClient.versionPath(for: "/users/app/password/reset")
            $0.httpMethod = .post
            $0.parameters = [
                "email": email
            ]
        })
        
        return prontoAPIClient.request(request).map { _ in }
    }
    
    func register(_ user: User, password: String) -> Single<User> {
        if let singleError = _checkValid(user: user) {
            return singleError
        }
        
        do {
            var obj: [String: Any] = try user.encode { encoder in
                guard let codingKey = CodingUserInfoKey(rawValue: "context") else {
                    return
                }
                encoder.userInfo = [
                    codingKey: "update_profile"
                ]
            }
            obj["password"] = password
            
            let request = Cobalt.Request({
                $0.httpMethod = .post
                $0.path = prontoAPIClient.versionPath(for: "/users/app/registration")
                $0.authentication = .oauth2(.clientCredentials)
                $0.parameters = obj
            })
            
            return prontoAPIClient.request(request).map { json -> User in
                return try json["data"].map(to: User.self)
            }
        } catch let error {
            return Single<User>.error(error)
        }
    }

    func unregister(_ user: User) -> Single<Void> {
        let request = Cobalt.Request({
            $0.httpMethod = .delete
            $0.authentication = .oauth2(.password)
            $0.path = prontoAPIClient.versionPath(for: "/users/app/registration/\(user.id)")
        })

        return prontoAPIClient.request(request).map { _ in }
    }
}
