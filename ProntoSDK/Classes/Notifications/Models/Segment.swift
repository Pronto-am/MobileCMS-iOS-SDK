//
//  Segment.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// The class that holds the push notifications segment
public class Segment: CustomStringConvertible, Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isSubscribed = "subscribed"
    }

    /// Unique ID
    internal(set) public var id: Int = 0

    /// The (localized) name of the segment
    internal(set) public var name: Text!

    /// Is the current device subscribed to that particular segment
    public var isSubscribed: Bool = false

    /// :nodoc:
    public var description: String {
        return "<Segment> [ id: \(id), name: \(name), isSubscribed: \(isSubscribed)  ]"
    }

    /// :nodoc:
    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.id == rhs.id
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isSubscribed, forKey: .isSubscribed)
    }
}
