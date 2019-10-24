//
//  ProntoAPIClient+remoteconfig.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 24/10/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation

private var remoteConfigMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    var remoteConfig: ProntoAPIClientRemoteConfigModule {
        return memoize(self, key: &remoteConfigMemoizationKey) {
            return ProntoAPIClientRemoteConfigModule(prontoAPIClient: self)
        }
    }
}
