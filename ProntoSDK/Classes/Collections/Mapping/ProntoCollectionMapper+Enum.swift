//
//  ProntoCollectionMapper+Enum.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

extension ProntoCollectionMapper {
    /// Map an enum value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `T: RawRepresentable`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: RawRepresentable>(key: String, to object: inout T) throws where T.RawValue == String {
        var tmpObject: T? = object
        try map(key: key, to: &tmpObject)
        if let assignNewObject = tmpObject {
            object = assignNewObject
        }
    }

    /// Map an enum value
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: (Optional) `T: RawRepresentable`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: RawRepresentable>(key: String, to object: inout T?) throws where T.RawValue == String {
        let jsonObject = json[key]
        guard let string = jsonObject.string else {
            return
        }
        object = T(rawValue: string)
    }

    /// Map an array of enums
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `[T: RawRepresentable]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: RawRepresentable>(key: String, to objects: inout [T]) throws where T.RawValue == String {
        var tmpObjects: [T]? = objects
        try map(key: key, to: &tmpObjects)
        if let assignNewObjects = tmpObjects {
            objects = assignNewObjects
        }
    }

    /// Map an array of enums
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: (Optional) `[T: RawRepresentable]`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: RawRepresentable>(key: String, to objects: inout [T]?) throws where T.RawValue == String {
        guard let array = json[key].array else {
            return
        }

        objects = array.compactMap { obj in
            if let string = obj.string,
                let object = T(rawValue: string) {
                return object
            }
            return nil
        }
    }
}
