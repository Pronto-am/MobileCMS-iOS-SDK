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

extension ProntoAPIClient: ReactiveCompatible { }

extension Reactive where Base: ProntoAPIClient {
    /// :nodoc:
    public var authorizationGrantType: Observable<Cobalt.OAuthenticationGrantType?> {
        return base.client.rx.authorizationGrantType
    }
}

private var usersMemoizationKey: UInt8 = 0

extension ProntoAPIClient {
    /// The Notifications module
    public var user: ProntoAPIClientUserModule {
        return memoize(self, key: &usersMemoizationKey) {
            return ProntoAPIClientUserModule(prontoAPIClient: self)
        }
    }
}
