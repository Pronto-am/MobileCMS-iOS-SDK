//
//  ProntoError.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Cobalt

/// Pronto specific errors
public enum ProntoError: Swift.Error {
    /// Unknown
    case unknown

    /// An error occured during the mapping of a JSON object to a Swift model
    case mapping

    /// Not found (404)
    case notFound

    /// Any other error
    case underlying(Swift.Error)

    /// Already Registered (code 1122)
    case alreadyRegistered

    /// Login / registration: Invalid E-mail address
    case invalidEmailAddress

    /// Login: Invalid credentials
    case invalidCredentials
    
    /// Missing a specific field
    case missingField(String)

    init(error: Swift.Error) {
        if let prontoError = error as? ProntoError {
            self = prontoError
            return

        } else if let apiError = error as? CobaltError {
            if let json = apiError.json {
                switch json["error"]["code"].intValue {
                case 1122:
                    self = .alreadyRegistered
                    return
                default:
                    break
                }
            }
        }
        self = .underlying(error)
    }

    init?(statusCode: Int) {
        switch statusCode {
        case 404:
            self = .notFound
        default:
            return nil
        }
    }
}

extension ProntoError: Equatable {
    /// :nodoc:
    public static func == (lhs: ProntoError, rhs: ProntoError) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }

    /// :nodoc:
    public static func == (lhs: Swift.Error, rhs: ProntoError) -> Bool {
        return ProntoError(error: lhs) == rhs
    }

    /// :nodoc:
    public static func == (lhs: ProntoError, rhs: Swift.Error) -> Bool {
        return rhs == lhs
    }
}
