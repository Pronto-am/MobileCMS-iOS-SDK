//
//  ProntoCollectionMapper.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

/// The main mapper class for all pronto related entry types
public class ProntoCollectionMapper {
    let json: JSON
    
    init(json: JSON) {
        self.json = json
    }

    static func createCollectionEntry<T: ProntoCollectionMappable>(type: T.Type, json: JSON) throws -> T {
        guard let id = json["id"].string else {
            throw ProntoCollectionError.mapping("id")
        }

        let mapper = ProntoCollectionMapper(json: json)
        var item = try T(mapper: mapper)
        item.id = id

        if let dateString = json["created_at"].string {
            item.createDate = DateFormatting.iso8601DateTimeFormatter.date(from: dateString) ?? Date()
        }

        if let dateString = json["updated_at"].string {
            item.updateDate = DateFormatting.iso8601DateTimeFormatter.date(from: dateString) ?? Date()
        }
        return item
    }

    /// Map a swift or normal pronto value to a key
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: `T: ProntoCollectionMappable`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: ProntoCollectionMapValue>(key: String, to object: inout T) throws {
        var tmpObject: T? = object
        try map(key: key, to: &tmpObject)
        if let assignNewObject = tmpObject {
            object = assignNewObject
        }
    }

    // swiftlint:disable function_body_length
    /// Map a swift or normal pronto value to a key
    ///
    /// - Parameters:
    ///  - key: `String`
    ///  - object: Optional `T: ProntoCollectionMappable`
    ///
    /// - Throws: `ProntoCollectionError`
    public func map<T: ProntoCollectionMapValue>(key: String, to object: inout T?) throws {
        let jsonObject = json[key]
        if jsonObject == .null {
            return
        }

        let stringMirror = Mirror(reflecting: object as Any)
        let type = stringMirror.subjectType

        if type == Optional<Coordinate>.self, let mappedObject = (try? jsonObject.map(to: Coordinate.self)) as? T {
            guard jsonObject.type == .dictionary || jsonObject.type == .string else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "dictionary || string")
            }
            object = mappedObject

        } else if type == Optional<Text>.self, let mappedObject = (try? jsonObject.map(to: Text.self)) as? T {
            guard jsonObject.type == .dictionary || jsonObject.type == .string else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "dictionary || string")
            }
            object = mappedObject

        } else if type == Optional<TextURL>.self,
            let mappedObject = (try? jsonObject.map(to: TextURL.self)) as? T {
            guard jsonObject.type == .dictionary || jsonObject.type == .string else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "dictionary || string")
            }
            object = mappedObject

        } else if type == Optional<Date>.self, let dateString = jsonObject.string {
            guard jsonObject.type == .string else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "string")
            }
            if let date = DateFormatting.iso8601DateTimeFormatter.date(from: dateString) {
                object = date as? T
                return
            }
            if let date = DateFormatting.iso8601DateFormatter.date(from: dateString) {
                object = date as? T
            }

        } else if type == Optional<Bool>.self {
            guard jsonObject.type == .bool else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "bool")
            }
            object = jsonObject.bool as? T

        } else if type == Optional<Int>.self {
            guard jsonObject.type == .number else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "int")
            }
            object = jsonObject.int as? T

        } else if type == Optional<Float>.self {
            guard jsonObject.type == .number else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "float")
            }
            object = jsonObject.float as? T

        } else if type == Optional<Double>.self {
            guard jsonObject.type == .number else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "double")
            }
            object = jsonObject.double as? T

        } else if type == Optional<String>.self {
            guard jsonObject.type == .string else {
                throw ProntoCollectionError.invalidType(key, "\(jsonObject.type)", "string")
            }
            object = jsonObject.string as? T
        } else {
            throw ProntoCollectionError.unknownType(key, "\(type)")
        }
    }
    // swiftlint:enable function_body_length}
}
