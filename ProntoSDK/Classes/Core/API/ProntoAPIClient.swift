//
//  ProntoAPIClient.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.

import Foundation
import Promises
import SwiftyJSON
import Cobalt

/// The main API Client for the Pronto API
///
/// Always use `ProntoAPIClient.default`
///
/// Initialization is done through `ProntoSDK.configure(...)`
public class ProntoAPIClient: PluginBase {

    var requiredPlugins: [ProntoPlugin] {
        return []
    }

    /// API documentation: https://prontocms.e-staging.nl/apidoc/index.html
    lazy var client: Cobalt.Client = {
        let config = Cobalt.Config({
            $0.clientID = ProntoSDK.config.clientID
            $0.host = host
            $0.clientSecret = ProntoSDK.config.clientSecret
            $0.logger = ProntoLogger
        })
        return Cobalt.Client(config: config)
    }()

    /// The default singleton
    public static let `default` = ProntoAPIClient()

    var host: String {
        return "https://\(ProntoSDK.config.domain)"
    }

    var base64DecodedAuthorization: String {
        let data = "\(ProntoSDK.config.clientID):\(ProntoSDK.config.clientSecret)".data(using: .utf8) ?? Data()
        return data.base64EncodedString()
    }

    lazy var firebaseLog = FirebaseLogModule(prontoAPIClient: self)

    private init() {

    }

    func configure() {
        if ProntoSDK.config.clientID.isEmpty || ProntoSDK.config.clientSecret.isEmpty {
            fatalError("clientID and clientSecret should be set prior to ProntoAPIClient.configure()")
        }
        client.config.clientID = ProntoSDK.config.clientID
        client.config.host = host
        client.config.clientSecret = ProntoSDK.config.clientSecret
        client.config.logger = ProntoLogger
    }

    /// Make a API request
    ///
    /// - Parameters:
    ///   - requestObject: `Cobalt.Request`
    ///
    /// - Returns: `Promise<JSON>`

    public func request(_ requestObject: Cobalt.Request) -> Promise<JSON> {
        return client.request(requestObject).recover { error throws -> Promise<JSON> in
            let prontoError = ProntoError(error: error)
            ProntoLogger.error("ProntoError: \(prontoError)")
            throw prontoError
        }
    }

    func versionPath(`for` path: String) -> String {
        var path = path
        if !path.hasPrefix("/") {
            path = "/\(path)"
        }
        return "/api/\(ProntoSDK.config.apiVersion)\(path)"
    }
}
