//
//  FirebaseLogModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 09/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import CryptoSwift
import Cobalt
import RxSwift
import RxCocoa

enum LogType: String {
    case notificationReceived = "notification_received"
    case notificationOpened = "notification_opened"
    case signInDevice = "signin_device"
    case signInUser = "signin_user"
}

class FirebaseLogModule {
    fileprivate struct Constants {
        fileprivate static let tableName: String = "pronto_logs"
        
        fileprivate static var encryptionKey: String {
            return ProntoSDK.config.encryptionKey ?? ""
        }
    }
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    @discardableResult
    func add(type: LogType, _ logParameters: [AnyHashable: Any]) throws -> Single<Void> {
        let initializationVector = String.random(size: 16)
        let cipherText: String
        do {
            let aes = try AES(key: Constants.encryptionKey, iv: initializationVector)
            let bytes = try aes.encrypt([UInt8](logParameters.rawJSONString.utf8))
            let data = Data(bytes)
            cipherText = data.base64EncodedString()
        } catch let error {
            ProntoLogger?.error("Error encrypting: \(error)")
            throw ProntoError(error: error)
        }
        let dateFormatter = DateFormatting.iso8601DateTimeFormatter
        let dateString = dateFormatter.string(from: Date())
        let parameters = [
            "type": type.rawValue,
            "date": dateString,
            "data": cipherText,
            "iv": initializationVector
        ]

        let requestObject = Cobalt.Request({
            $0.host = "https://\(ProntoSDK.config.firebaseDomain)"
            $0.path = "/\(Constants.tableName).json"
            $0.httpMethod = .post
            $0.parameters = parameters
        })

        return prontoAPIClient.request(requestObject).map { _ in () }
    }
}
