//
//  ProntoCollectionMapper+Relation.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

extension ProntoCollectionMapper {
    /// Map a collection relation
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `T: ProntoCollectionMappable`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: ProntoCollectionMappable>(key: String, to object: inout T) throws {
        var tmpObject: T? = object
        try map(key: key, to: &tmpObject)
        if let assignNewObject = tmpObject {
            object = assignNewObject
        }
    }

    /// Map a collection relation
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: (Optional) `T: ProntoCollectionMappable`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: ProntoCollectionMappable>(key: String, to object: inout T?) throws {
        let jsonObject = json[key]
        if jsonObject == .null {
            return
        }
        object = try ProntoCollectionMapper.createCollectionEntry(type: T.self, json: jsonObject)
    }

    /// Map an array of collection relations
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `[T: ProntoCollectionMappable]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: ProntoCollectionMappable>(key: String, to objects: inout [T]) throws {
        var tmpObjects: [T]? = objects
        try map(key: key, to: &tmpObjects)
        if let assignNewObjects = tmpObjects {
            objects = assignNewObjects
        }
    }

    /// Map an array of collection relations
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: (Optional) `[T: ProntoCollectionMappable]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: ProntoCollectionMappable>(key: String, to objects: inout [T]?) throws {
        guard let array = json[key].array else {
            return
        }

        objects = array.compactMap { jsonObject in
            if jsonObject == .null {
                return nil
            }
            return try? ProntoCollectionMapper.createCollectionEntry(type: T.self, json: jsonObject)
        }
    }
}
