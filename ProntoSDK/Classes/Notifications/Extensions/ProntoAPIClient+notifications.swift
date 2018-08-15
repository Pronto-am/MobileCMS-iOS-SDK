//
//  ProntoAPIClient+notification.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

private var notificationsMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    /// The Notifications module
    public var notifications: ProntoAPIClientNotificationsModule {
        return memoize(self, key: &notificationsMemoizationKey) {
            return ProntoAPIClientNotificationsModule(prontoAPIClient: self)
        }
    }
}
