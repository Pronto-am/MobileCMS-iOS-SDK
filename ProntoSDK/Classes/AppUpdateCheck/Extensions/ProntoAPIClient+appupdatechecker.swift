//
//  ProntoAPIClient+appupdatechecker.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 12/02/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation

private var appUpdateCheckerMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    /// The App Update Checker module
    var appUpdateChecker: ProntoAPIClientAppUpdateCheckModule {
        return memoize(self, key: &appUpdateCheckerMemoizationKey) {
            return ProntoAPIClientAppUpdateCheckModule(prontoAPIClient: self)
        }
    }
}
