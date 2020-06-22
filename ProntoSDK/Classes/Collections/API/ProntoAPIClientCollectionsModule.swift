//
//  ProntoAPIClientCollectionsModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Cobalt
import SwiftyJSON
import Alamofire

class ProntoAPIClientCollectionsModule {
    private weak var prontoAPIClient: ProntoAPIClient!
    
    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }
    
    func list(name: String,
              sortBy sortOrder: SortOrder? = nil,
              parameters queryParameters: [String: String]? = nil,
              pagination: Pagination) -> Single<JSON> {
        var parameters: Parameters = [
            "offset": pagination.offset,
            "limit": pagination.limit
        ]
        if let sortOrder = sortOrder {
            parameters["order_by"] = sortOrder.key
            parameters["direction"] = sortOrder.direction.rawValue
        }
        if var queryParameters = queryParameters {
            [ "offset", "limit", "order_by", "direction" ].forEach {
                queryParameters.removeValue(forKey: $0)
            }
            for (key, value) in queryParameters {
                parameters[key] = value
            }
        }
        let request = Cobalt.Request({
            $0.httpMethod = .get
            $0.authentication = .oauth2(.clientCredentials)
            $0.parameters = parameters
            let applicationVersion = ProntoSDK.config.applicationVersion
            $0.path = prontoAPIClient.versionPath(for: "/collections/\(applicationVersion)/\(name)")
        })
        
        return prontoAPIClient.request(request)
    }
    
    func get(name: String, id: String) -> Single<JSON> {
        let request = Cobalt.Request({
            $0.httpMethod = .get
            $0.authentication = .oauth2(.clientCredentials)
            let applicationVersion = ProntoSDK.config.applicationVersion
            $0.path = prontoAPIClient.versionPath(for: "/collections/\(applicationVersion)/\(name)/\(id)")
        })

        return prontoAPIClient.request(request)
    }
}
