//
//  ProntoAPIClientLocalizationModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 23/05/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Cobalt
import SwiftyJSON

class ProntoAPIClientLocalizationModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    @discardableResult
    func fetch() -> Single<[String: [String: String]]> {
        let requestObject = Cobalt.Request({
            $0.path = prontoAPIClient.versionPath(for: "/translations")
            $0.httpMethod = .get
            $0.authentication = .oauth2(.clientCredentials)
            $0.loggingOption = LoggingOption(response: [ "data": .replaced("Hidden") ])
        })

        return prontoAPIClient
            .request(requestObject)
            .map { json -> [String: [String: String]] in
                var dictionary: [String: [String: String]] = [:]
                for keyValue in json["data"].arrayValue {
                    guard let identifier = keyValue["identifier"].string,
                        !identifier.isEmpty,
                        keyValue["type"] == "app",
                        keyValue["ios"].boolValue == true else {
                            continue
                    }
                    var translationDictionary: [String: String] = [:]
                    for jsonObj in keyValue["translations"].arrayValue {
                        guard let language = jsonObj["language"].string, !language.isEmpty else {
                            continue
                        }
                        translationDictionary[language] = jsonObj["text"].stringValue
                    }

                    if translationDictionary.isEmpty {
                        continue
                    }

                    dictionary[identifier] = translationDictionary
                }

                return dictionary
            }
    }
}
