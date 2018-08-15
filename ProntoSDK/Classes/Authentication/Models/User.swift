//
//  User.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 28/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Cobalt

/// A pronto (app) user
public class User: Codable, CustomStringConvertible {
    enum CodingKeys: String, CodingKey {
        case id
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
        case isActivated = "activated"
        case extraData = "extra_data"
    }

    /// The (unique) id
    internal(set) public var id: String = ""

    /// The (unique) username; aka e-mail
    public var email: String = ""

    /// User's first name
    public var firstName: String = ""

    /// User's last name
    public var lastName: String = ""

    /// User's activation
    private(set) public var isActivated: Bool = false

    /// User's extra data
    public var extraData: [String: String]?

    /// Empty constructor
    public init() {
        
    }

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        isActivated = try container.decode(Bool.self, forKey: .isActivated)
        extraData = try container.decodeIfPresent([String: String].self, forKey: .extraData)
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(isActivated, forKey: .isActivated)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(extraData ?? [:], forKey: .extraData)
    }

    /// :nodoc:
    public var description: String {
        return "<User> [ id: \(id), " +
            "email: \(email), " +
            "isActivated: \(isActivated), " +
            "firstName: \(firstName), " +
            "lastName: \(lastName) " +
        "]"
    }
}
