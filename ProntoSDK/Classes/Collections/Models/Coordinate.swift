//
//  Coordinate.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import CoreLocation

/// A coordinate entry type
public class Coordinate: Decodable, ProntoCollectionMapValue, CustomStringConvertible {
    enum CodingKeys: String, CodingKey {
        case coordinate
        case address
        case latitude
        case longitude
    }

    /// The actual latitude and longitude
    public var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    /// Optional coordinate name (address)
    public var address: String?

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decodeIfPresent(String.self, forKey: .address)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// :nodoc:
    public var description: String {
        return "<Coordinate> [ coordinate: \(coordinate), address: \(String(describing: address)) ]"
    }
}
