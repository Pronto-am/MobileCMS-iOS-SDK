//
//  Models.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 02/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
@testable import ProntoSDK

extension User {
    static func mock() -> User {
        let user = User()
        user.email = "bas@e-sites.nl"
        user.firstName = "Bas"
        user.lastName = "van Kuijck"
        user.extraData = [
            "gender": "male"
        ]

        return user
    }
}

extension Device {
    static func mock() -> Device {
        let device = Device()
        device.deviceToken = "T52FE6488A74BA264C12E42BF49C8F675D1654393A1ADAE8D9D238947905E525"
        device.id = "02f88251-f4e1-45db-ad8d-288947758bb3"
        return device
    }
}

class AllTestModel: ProntoCollectionMappable, CustomStringConvertible {
    enum Select: String {
        case key1
        case key2
        case key3
    }

    static var collectionName: String {
        return "alles"
    }

    var createDate: Date = Date()
    var updateDate: Date = Date()
    var id: String = ""
    var text: Text?
    var multiText: Text?
    var htmlText: Text?
    var url: TextURL?
    var singleURL: URL?
    var coordinate: Coordinate?
    var bool: Bool = false
    var select: Select?
    var int: Int = 0
    var multiSelect: [Select] = []
    var json: [String: Any]?
    var date: Date = Date()
    var related: RelatedModel?
    var relations: [AllTestModel] = []

    init() {
        
    }

    required init(mapper: ProntoCollectionMapper) throws {
        try mapper.map(key: "text", to: &text)
        try mapper.map(key: "multilinetext", to: &multiText)
        try mapper.map(key: "htmltext", to: &htmlText)
        try mapper.map(key: "boolean", to: &bool)
        try mapper.map(key: "coordinates", to: &coordinate)
        try mapper.map(key: "url", to: &url)
        try mapper.map(key: "number", to: &int)
        try mapper.map(key: "date", to: &date)
        try mapper.map(key: "json", to: &json)
        try mapper.map(key: "select", to: &select)
        try mapper.map(key: "selectmulti", to: &multiSelect)
        try mapper.map(key: "related", to: &related)
        try mapper.map(key: "relations", to: &relations)
        try mapper.map(key: "singleURL", to: &singleURL)
    }

    var description: String {
        return "<All> [ id: \(id), " +
            "text: \(String(describing: text)), " +
            "multiText: \(String(describing: multiText)), " +
            "htmlText: \(String(describing: htmlText)), " +
            "coordinate: \(String(describing: coordinate)), " +
            "int: \(String(describing: int)), " +
            "url: \(String(describing: url)), " +
            "select: \(String(describing: select)), " +
            "multiSelect: \(String(describing: multiSelect)), " +
            "bool: \(String(describing: bool)) " +
        "]"
    }
}

class RelatedModel: ProntoCollectionMappable {
    required init(mapper: ProntoCollectionMapper) throws {
        try mapper.map(key: "name", to: &name)
    }

    static var collectionName: String {
        return "related"
    }

    var createDate: Date = Date()
    var updateDate: Date = Date()
    var id: String = ""
    var name: Text?
}
