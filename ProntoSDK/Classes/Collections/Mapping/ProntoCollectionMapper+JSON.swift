//
//  ProntoCollectionMapper+JSON.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 23/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ProntoCollectionMapper {
    /// Map a dictionary value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `[String: Any]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map(key: String, to object: inout [String: Any]) throws {
        var tmpObject: [String: Any]? = object
        try map(key: key, to: &tmpObject)
        if let assignNewObject = tmpObject {
            object = assignNewObject
        }
    }

    /// Map a dictionary value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: (Optional) `[String: Any]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map(key: String, to object: inout [String: Any]?) throws {
        object = json[key].dictionaryObject
    }

    /// Map an array value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `[Any]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map(key: String, to object: inout [Any]) throws {
        var tmpObject: [Any]? = object
        try map(key: key, to: &tmpObject)
        if let assignNewObject = tmpObject {
            object = assignNewObject
        }
    }

    /// Map an array value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: (Optional) `[Any]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map(key: String, to object: inout [Any]?) throws {
        object = json[key].arrayObject
    }
}
