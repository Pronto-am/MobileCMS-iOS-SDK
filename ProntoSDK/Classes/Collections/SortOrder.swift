//
//  SortOrder.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// Add a sort_by query parameter
public struct SortOrder {
    /// In which direction
    public enum Direction: String {
        /// Ascending (A -> Z)
        case ascending = "ASC"

        /// Descending (Z -> A)
        case descending = "DESC"
    }

    /// The field to sort by
    public let key: String

    /// The direction of the sort
    /// - See `Direction`
    public let direction: Direction

    /// Constructor
    ///
    /// - Parameters:
    ///   - key: `String` . The column name
    ///   - direction: `Direction` (Default = .ascending)
    public init(key: String, direction: Direction = Direction.ascending) {
        self.key = key
        self.direction = direction
    }
}
