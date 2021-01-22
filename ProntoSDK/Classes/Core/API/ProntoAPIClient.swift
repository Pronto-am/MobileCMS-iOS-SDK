//
//  ProntoAPIClient.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.

import Foundation
import RxSwift
import RxCocoa
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
        let config = Cobalt.Config {
            $0.authentication.clientID = ProntoSDK.config.clientID
            $0.authentication.clientSecret = ProntoSDK.config.clientSecret
            $0.host = host
            $0.logging.logger = ProntoLogger
            #if !DEBUG
            $0.logging.maskTokens = true
            #endif
        }
        return Cobalt.Client(config: config)
    }()

    /// The default singleton
    public static let `default` = ProntoAPIClient()
    
    public var accessToken: String? {
        return self.client.accessToken?.accessToken
    }

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
        client.config.authentication.clientID = ProntoSDK.config.clientID
        client.config.authentication.clientSecret = ProntoSDK.config.clientSecret
        client.config.logging.logger = ProntoLogger
        client.config.host = host
    }

    /// Make a API request
    ///
    /// - Parameters:
    ///   - requestObject: `Cobalt.Request`
    ///
    /// - Returns: `Promise<JSON>`

    public func request(_ requestObject: Cobalt.Request) -> Single<JSON> {
        requestObject.headers?["Accept-Language"] = ProntoSDK.config.defaultLocale.identifier
        return client.request(requestObject).catchError { error throws -> Single<JSON> in
            let prontoError = ProntoError(error: error)
            if let logReq = requestObject.loggingOption?.request?["*"], case KeyLoggingOption.ignore = logReq {
            } else {
                ProntoLogger?.error("ProntoError: \(prontoError)")
            }
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
