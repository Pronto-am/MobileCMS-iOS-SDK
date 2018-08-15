//
//  ProntoCollectionError.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// ProntoCollectionError enum
public enum ProntoCollectionError: Swift.Error, CustomStringConvertible {
    /// Error thrown when mapping fails. (key)
    case mapping(String)

    /// Unknown type. (key, type)
    case unknownType(String, String)

    /// Invalid type. (key, type, expectingType)
    case invalidType(String, String, String)

    /// :nodoc:
    public var description: String {
        switch self {
        case .mapping(let key):
            return "ProntoCollectionError.mapping on '\(key)'"

        case .unknownType(let key, let type):
            return "ProntoCollectionError.unknownType \(type) for '\(key)'"

        case .invalidType(let key, let type, let expecting):
            return "ProntoCollectionError.invalidType \(type) for '\(key)', expecting: \(expecting)"
        }
    }
}
