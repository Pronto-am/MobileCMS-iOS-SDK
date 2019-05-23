//
//  ProntoAPIClient+localization.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 23/05/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation

private var localizationMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    /// The Notifications module
    var localization: ProntoAPIClientLocalizationModule {
        return memoize(self, key: &localizationMemoizationKey) {
            return ProntoAPIClientLocalizationModule(prontoAPIClient: self)
        }
    }
}
