//
//  ProntoAuthentication+authentication.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 28/05/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation
import Cobalt
import RxSwift

extension ProntoAuthentication: ReactiveCompatible { }

extension Reactive where Base: ProntoAuthentication {
    var authorizationGrantType: Observable<Cobalt.OAuthenticationGrantType?> {
        return base.apiClient.client.rx.authorizationGrantType
    }
}
