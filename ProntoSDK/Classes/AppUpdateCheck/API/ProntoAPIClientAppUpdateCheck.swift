//
//  ProntoAPIClientAppUpdateCheckModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 12/02/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation
import Promises
import Cobalt

class ProntoAPIClientAppUpdateCheckModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    func check() -> Promise<AppVersion> {
        let requestObject = Cobalt.Request {
            $0.path = "/bundles/prontomobile/versions.php"
            $0.authentication = .oauth2(.clientCredentials)
            $0.parameters = [
                "version": Bundle.main.version,
                "platform": "ios"
            ]
        }

        return prontoAPIClient.request(requestObject).then { json in
            let appVersion = try json.map(to: AppVersion.self)
            return Promise(appVersion)
        }
    }
}
