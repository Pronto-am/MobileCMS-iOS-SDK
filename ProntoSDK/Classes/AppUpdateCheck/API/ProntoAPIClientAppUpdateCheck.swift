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
import Erbium
import UIKit

class ProntoAPIClientAppUpdateCheckModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    func check() -> Promise<AppVersion> {
        var version = Bundle.main.version
        let count = version.components(separatedBy: ".").count
        if count == 1 {
            version += ".0.0"
        } else if count == 2 {
            version += ".0"
        }
        let requestObject = Cobalt.Request {
            $0.path = "/bundles/prontomobile/versions.php"
            $0.authentication = .oauth2(.clientCredentials)
            $0.parameters = [
                "version": version,
                "platform": "ios"
            ]
        }

        return prontoAPIClient.request(requestObject).then { json in
            let appVersion = try json.map(to: AppVersion.self)
            return Promise(appVersion)
        }
    }
}
