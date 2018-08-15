//
//  ProntoCollection.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import SwiftyJSON
import Cobalt
import Promises

/// Helper class to handle all the collections logic
public class ProntoCollection<CollectionType: ProntoCollectionMappable>: PluginBase {
    var requiredPlugins: [ProntoPlugin] {
        return [ .collections ]
    }

    /// Default constructor
    private weak var apiClient: ProntoAPIClient!

    /// Default contructor
    public convenience init() {
        self.init(apiClient: ProntoAPIClient.default)
    }

    init(apiClient: ProntoAPIClient) {
        self.apiClient = apiClient
        checkPlugin()
    }

    func configure() {
    }

    /// Returns a paginated result of the selected collection
    ///
    /// - Parameters:
    ///   - sortBy: (Optional) `SortOrder` Sortation
    ///   - filterBy: (Optional) `[String: ProntoFilterable]` To filter the results from the API side
    ///   - pagination: `Pagination` (default: `Pagination()`)
    ///
    /// - Returns: `Promise<PaginatedResult<CollectionType>>`
    public func list(sortBy: SortOrder? = nil,
                     filterBy: [String: ProntoFilterable]? = nil,
                     pagination: Pagination = Pagination()) -> Promise<PaginatedResult<CollectionType>> {
        let filterDictionary = filterBy?.mapValues { $0.filterValue }

        return apiClient.collections.list(
            name: CollectionType.collectionName,
            sortBy: sortBy,
            parameters: filterDictionary,
            pagination: pagination)
            .then { json -> Promise<PaginatedResult<CollectionType>> in
                let items = try json["data"].arrayValue.map {
                    try ProntoCollectionMapper.createCollectionEntry(type: CollectionType.self, json: $0)
                }
                var pagination = pagination
                pagination.total = json["pagination"]["total"].int
                
                let result = PaginatedResult(pagination: pagination, items: items)
                return Promise(result)
            }
    }

    /// Collection detail
    ///
    /// - Parameters:
    ///   - id: `String` the unique ID of the collection entry
    ///
    /// - Returns: `Promise<CollectionType>`
    public func get(id: String) -> Promise<CollectionType> {
        return apiClient.collections.get(name: CollectionType.collectionName, id: id)
            .then { json -> Promise<CollectionType> in
                let item = try ProntoCollectionMapper.createCollectionEntry(type: CollectionType.self,
                                                                               json: json["data"])
                return Promise(item)
            }
    }
}
