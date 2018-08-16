//
//  Pagination.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// Define how the pagination (offset + limit) of the list request should be
public struct Pagination {

    /// The initial offset
    public var offset: Int

    /// The limit per page
    public var limit: Int

    /// The total number of items for the collection
    internal(set) public var total: Int?

    /// Does the pagination hold any more results
    public var hasMoreResults: Bool {
        return next() != nil
    }

    /// Create a new pagination object request
    ///
    /// - Parameters
    ///  - offset: `Int` (Default: 0)
    ///  - limit: `Int` (Default: 25)
    public init(offset: Int = 0, limit: Int = 25) {
        self.offset = offset
        self.limit = limit
    }

    /// Generates a new Pagination instance for the next page
    ///
    /// - Returns: (Optional) `Pagination`
    public func next() -> Pagination? {
        guard let total = self.total else {
            return nil
        }

        let offset = self.offset + limit
        if offset >= total {
            return nil
        }
        var newPagination = Pagination(offset: offset, limit: limit)
        newPagination.total = self.total
        return newPagination
    }

    /// Generates a new Pagination instance for the previous page
    ///
    /// - Returns: (Optional) `Pagination`
    public func previous() -> Pagination? {
        if self.offset <= 0 {
            return nil
        }
        let offset = self.offset - limit
        var newPagination = Pagination(offset: offset, limit: limit)
        newPagination.total = self.total
        return newPagination
    }
}
