//
//  RemoteConfigItem.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 24/10/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation

//{
//            "id": 1,
//            "release_date": null,
//            "android": true,
//            "ios": true,
//            "name": "Pronto rules",
//            "identifier": "pronto_does_rule",
//            "description": "Describes the ruleness level of Pronto on a scale of 1 - 10",
//            "type": "integer",
//            "value": 12,
//            "created_at": "2019-10-23T15:39:16+0200",
//            "updated_at": "2019-10-23T15:39:16+0200"
//        }

/// A remote config item
public class RemoteConfigItem: Codable, CustomDebugStringConvertible {

    /// The Remote config type
    public enum ItemType: String, Codable {
        /// Integer
        case integer

        /// String
        case string

        /// Boolean
        case boolean

        /// JSON
        case json
    }

    private enum CodingKeys: String, CodingKey {
        case isIOS = "ios"
        case id
        case name
        case itemType = "type"
        case description
        case identifier
        case value
        case releaseDate = "release_date"
    }

    var isIOS: Bool = true

    /// The unique remote config item id
    internal(set) public var id: Int = 0

    /// The descriptive name of the remote config item
    internal(set) public var name: String = ""

    /// The identifier (aka unique key)
    internal(set) public var identifier: String = ""

    /// The type
    internal(set) public var itemType: ItemType = .integer

    /// The decsription of the item
    internal(set) public var description: String?

    /// Bool value
    private(set) var boolValue: Bool?

    /// Integer value
    private(set) var integerValue: Int?

    /// String value
    private(set) var stringValue: String?

    /// Dictionary value (JSON type)
    private(set) var dictionaryValue: [String: String]?

    /// The date when this items was available
    private(set) public var releaseDate: Date?

    /// :nodoc:
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isIOS = try container.decode(Bool.self, forKey: .isIOS)
        name = try container.decode(String.self, forKey: .name)
        identifier = try container.decode(String.self, forKey: .identifier)
        itemType = try container.decode(ItemType.self, forKey: .itemType)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)

        switch itemType {
        case .boolean:
            boolValue = try container.decode(Bool.self, forKey: .value)
            
        case .integer:
            integerValue = try container.decode(Int.self, forKey: .value)

        case .string:
            stringValue = try container.decode(String.self, forKey: .value)

        case .json:
            dictionaryValue = try container.decode([String: String].self, forKey: .value)
        }
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isIOS, forKey: .isIOS)
        try container.encode(name, forKey: .name)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(itemType, forKey: .itemType)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(releaseDate, forKey: .releaseDate)

        switch itemType {
        case .boolean:
            try container.encodeIfPresent(boolValue, forKey: .value)
        case .integer:
            try container.encodeIfPresent(integerValue, forKey: .value)
        case .string:
            try container.encodeIfPresent(stringValue, forKey: .value)
        case .json:
            try container.encodeIfPresent(dictionaryValue, forKey: .value)
        }

    }

    /// :nodoc:
    public var debugDescription: String {
        return "<RemoteConfigItem> [ id: \(id), name: \(name), identifier: \(identifier) ]"
    }
}
