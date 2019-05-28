//
//  ProntoAPIClient+authentication.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Cobalt
import RxSwift

private var usersMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    /// The Notifications module
    var user: ProntoAPIClientUserModule {
        return memoize(self, key: &usersMemoizationKey) {
            return ProntoAPIClientUserModule(prontoAPIClient: self)
        }
    }
}
