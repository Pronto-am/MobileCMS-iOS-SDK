//
//  ProntoCollectionMappable.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import CoreLocation

/// Extend your class, struct or enum with this protocol, to make it mappable
public protocol ProntoCollectionMappable: ProntoFilterable {

    /// The name (identifier) of the collection (e.g. "locations")
    static var collectionName: String { get }

    /// The creation date of the entry
    var createDate: Date { get set }

    /// The update date of the entry
    var updateDate: Date { get set }

    /// The unique id of the entry
    var id: String { get set }

    /// Implement this to map your variables to specific keys
    ///
    /// - Parameters:
    ///  - mapper: `ProntoCollectionMapper`
    ///
    /// - Throws: `ProntoCollectionError`
    ///
    /// *Example:*
    ///
    /// ```
    ///  required init(mapper: ProntoCollectionMapper) throws {
    ///      try mapper.map(key: "text", to: &text)
    ///      try mapper.map(key: "select", to: &select)
    ///      try mapper.map(key: "relations", to: &relations)
    /// }
    /// ```
    init(mapper: ProntoCollectionMapper) throws
}

extension ProntoCollectionMappable {
    var filterValue: String {
        return id
    }
}

/// Individual mappable values (e.g. string, int, date, etc)
public protocol ProntoCollectionMapValue { }

extension Text: ProntoCollectionMapValue { }
extension Bool: ProntoCollectionMapValue { }
extension Int: ProntoCollectionMapValue { }
extension String: ProntoCollectionMapValue { }
extension Date: ProntoCollectionMapValue { }
extension Double: ProntoCollectionMapValue { }
extension Float: ProntoCollectionMapValue { }
