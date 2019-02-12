//
//  AppVersion.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 12/02/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation

/// AppVersion class
/// Used to check for new app versions
public class AppVersion: Decodable, CustomStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case id
        case version
        case descriptionText = "description"
        case url
        case isRequired = "required"
    }

    var id: Int = 0

    /// The URL to redirect the user to, to download the update
    public internal(set) var url: String = ""

    /// The new version
    public internal(set) var version: String = ""

    /// Any information that belongs to the app update
    public internal(set) var descriptionText: Text?

    /// Is this update a required update. (e.g. the user cannot continue without updating)
    public internal(set) var isRequired = false

    public var description: String {
        return "<AppVersion> [ version: \(version), isRequired: \(isRequired) ]"
    }
}
