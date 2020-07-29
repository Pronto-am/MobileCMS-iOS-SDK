//
//  File.swift
//  
//
//  Created by Thomas Roovers on 28/07/2020.
//

import Foundation

public class SentPushNotification: CustomStringConvertible, Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case sent
    }
    
    /// Unique ID
    internal(set) public var id: String = ""

    /// The (localized) title of the notification
    internal(set) public var title: Text!

    /// The (localized) content of the notification
    internal(set) public var content: Text!

    /// Is the current device subscribed to that particular segment
    public var sent: Date = Date()

    /// :nodoc:
    public var description: String {
        return "<SentPushNotification> [ id: \(id), title: \(String(describing: title)), sent: \(sent)  ]"
    }

    /// :nodoc:
    public static func == (lhs: SentPushNotification, rhs: SentPushNotification) -> Bool {
        return lhs.id == rhs.id
    }
}
