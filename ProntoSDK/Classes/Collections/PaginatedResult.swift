//
//  PaginatedResult.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// The results of a Collection.list()
/// It's bundled into a seperate `PaginatedResult` generic, because we want to know how many items the collection
/// has in total.
public class PaginatedResult<CollectionType: ProntoCollectionMappable> {
    /// Pagination
    public let pagination: Pagination

    /// The collection items
    public let items: [CollectionType]

    init(pagination: Pagination, items: [CollectionType]) {
        self.items = items
        self.pagination = pagination
    }
}
