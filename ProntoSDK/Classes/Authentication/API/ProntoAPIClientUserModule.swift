//
//  ProntoAPIClientUserModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 28/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Promises
import Cobalt
import SwiftyJSON

/// For all (app) user related API calls
public class ProntoAPIClientUserModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    /// Get the user profile of the current access-token
    ///
    /// - Returns: `Promise<User>`
    public func profile() -> Promise<User> {
        let request = Cobalt.Request({
            $0.authentication = .oauth2(.password)
            $0.path = prontoAPIClient.versionPath(for: "/users/app/profile")
        })

        return prontoAPIClient.request(request).then { json -> Promise<User> in
            let user = try json["data"].map(to: User.self)
            return Promise(user)
        }
    }

    /// Updates the user's profile
    ///
    /// - Parameters:
    ///   - user: `User` The user
    ///
    /// - Returns: `Promise<User>`
    public func update(_ user: User) -> Promise<User> {
        do {
            let obj = try user.encode()

            let request = Cobalt.Request({
                $0.authentication = .oauth2(.password)
                $0.path = prontoAPIClient.versionPath(for: "/users/app/profile")
                $0.httpMethod = .put
                $0.parameters = obj
            })

            return prontoAPIClient.request(request).then { json -> Promise<User> in
                let user = try json["data"].map(to: User.self)
                return Promise(user)
            }
        } catch let error {
            return Promise<User>(error)
        }
    }
    
    /// Requests a password forgotten change request
    ///
    /// - Parameters:
    ///  - email: String The email address
    ///
    /// - Returns: `Promise<Void>`
    public func passwordResetRequest(email: String) -> Promise<Void> {
        let request = Cobalt.Request({
            $0.authentication = .oauth2(.clientCredentials)
            $0.path = prontoAPIClient.versionPath(for: "/users/app/password/reset")
            $0.httpMethod = .post
            $0.parameters = [
                "email": email
            ]
        })
        
        return prontoAPIClient.request(request).then { _ -> Promise<Void> in
            return Promise(())
        }
    }

    func register(_ user: User, password: String) -> Promise<User> {
        do {
            var obj: [String: Any] = try user.encode()
            obj["password"] = password

            let request = Cobalt.Request({
                $0.httpMethod = .post
                $0.path = prontoAPIClient.versionPath(for: "/users/app/registration")
                $0.authentication = .oauth2(.clientCredentials)
                $0.parameters = obj
            })

            return prontoAPIClient.request(request).then { json -> Promise<User> in
                let user = try json["data"].map(to: User.self)
                return Promise(user)
            }
        } catch let error {
            return Promise<User>(error)
        }
    }

    func unregister(_ user: User) -> Promise<Void> {
        let request = Cobalt.Request({
            $0.httpMethod = .delete
            $0.authentication = .oauth2(.password)
            $0.path = prontoAPIClient.versionPath(for: "/users/app/registration/\(user.id)")
        })

        return prontoAPIClient.request(request).then { _ -> Promise<Void> in
            return Promise(())
        }
    }
}
