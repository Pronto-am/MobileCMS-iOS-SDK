//
//  ProntoAPIClientRemoteConfigModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 24/10/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Promises
import Cobalt

class ProntoAPIClientRemoteConfigModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    func fetch() -> Promise<[RemoteConfigItem]> {
        let requestObject = Cobalt.Request {
            $0.authentication = .oauth2(.clientCredentials)
            $0.path = prontoAPIClient.versionPath(for: "/config")
        }

        return prontoAPIClient.request(requestObject).then { json in
            let items = try json["data"]
                .map(to: [RemoteConfigItem].self) { $0.dateDecodingStrategy = .iso8601 }
                .filter { $0.isIOS }
            return Promise(items)
        }
    }
}
