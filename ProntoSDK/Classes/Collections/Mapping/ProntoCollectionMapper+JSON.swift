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
    public func map<T>(key: String, to object: inout [String: T]) throws {
        var tmpObject: [String: T]? = object
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
    public func map<T>(key: String, to object: inout [String: T]?) throws {
        object = json[key].dictionaryObject as? [String: T]
    }

    /// Map an array value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `[Any]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T>(key: String, to object: inout [T]) throws {
        var tmpObject: [T]? = object
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
    public func map<T>(key: String, to object: inout [T]?) throws {
        object = json[key].arrayObject as? [T]
    }
}
