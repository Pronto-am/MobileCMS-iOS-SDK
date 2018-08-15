//
//  ProntoAPIClient+collections.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

private var collectionMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    /// The Collections module
    var collections: ProntoAPIClientCollectionsModule {
        return memoize(self, key: &collectionMemoizationKey) {
            return ProntoAPIClientCollectionsModule(prontoAPIClient: self)
        }
    }
}
