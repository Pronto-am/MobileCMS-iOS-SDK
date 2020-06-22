//
//  ProntoAPIClientNotificationsModule.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Erbium
import Cobalt
import UIKit

class ProntoAPIClientNotificationsModule {
    private weak var prontoAPIClient: ProntoAPIClient!

    init(prontoAPIClient: ProntoAPIClient) {
        self.prontoAPIClient = prontoAPIClient
    }

    private func _parameters(withDeviceToken deviceToken: String,
                             additionalData: [String: Any]) -> Parameters {
        return [
            "apns_token": deviceToken,
            "name": UIDevice.current.name,
            "model": Erbium.Device.version.name,
            "manufacturer": "Apple",
            "platform": "iOS",
            "language": Locale.current.languageCode?.uppercased() ?? "EN",
            "app_version": Bundle.main.version,
            "os_version": UIDevice.current.systemVersion,
            "extra_data": additionalData
        ]
    }

    @discardableResult
    func registerDevice(deviceToken: String,
                        sandbox: Bool = false,
                        additionalData: [String: Any] = [:]) -> Single<Device> {
        let parameters = _parameters(withDeviceToken: deviceToken, additionalData: additionalData)
        // TODO: Enable sandbox mode
//        if sandbox {
//            parameters["sandbox"] = true
//        }
        let requestObject = Cobalt.Request({
            $0.path = prontoAPIClient.versionPath(for: "/devices/registration")
            $0.httpMethod = .post
            $0.authentication = .oauth2(.clientCredentials)
            $0.parameters = parameters
        })

        return prontoAPIClient.request(requestObject).map { json -> Device in
            let jsonData = json["data"]
            let device = try jsonData.map(to: Device.self)
            device.store()
            return device
        }
    }

    @discardableResult
    func signIn(device: Device, additionalData: [String: Any] = [:]) -> Single<Void> {
        var parameters = _parameters(withDeviceToken: device.deviceToken,
                                     additionalData: additionalData)
        parameters["device_identifier"] = device.id
        return Single<Void>.just(()).flatMap { [prontoAPIClient] _ in
            guard let prontoAPIClient = prontoAPIClient else {
                return Single<Void>.never()
            }
            return try prontoAPIClient.firebaseLog.add(type: .signInDevice, parameters)
        }
    }

    @discardableResult
    func notificationReceived(notificationIdentifier: String, device: Device) -> Single<Void> {
        return Single<Void>.just(()).flatMap { [prontoAPIClient] _ in
            guard let prontoAPIClient = prontoAPIClient else {
                return Single<Void>.never()
            }
            return try prontoAPIClient.firebaseLog.add(type: .notificationReceived, [
                "notification_identifier": notificationIdentifier,
                "device_identifier": device.id
            ])
        }
    }

    @discardableResult
    func notificationOpened(notificationIdentifier: String, device: Device) -> Single<Void> {
        return Single<Void>.just(()).flatMap { [prontoAPIClient] _ in
            guard let prontoAPIClient = prontoAPIClient else {
                return Single<Void>.never()
            }
            return try prontoAPIClient.firebaseLog.add(type: .notificationOpened, [
                "notification_identifier": notificationIdentifier,
                "device_identifier": device.id
            ])
        }
    }
}

// MARK: - Unregister
// --------------------------------------------------------

extension ProntoAPIClientNotificationsModule {

    /// Unregisters a specific Device
    ///
    /// - Parameters:
    ///   - device: `Device`. Probably the `Device.current`
    ///
    /// - Returns: `Promise<Void>`
    @discardableResult
    func unregister(device: Device) -> Single<Void> {
        let requestObject = Cobalt.Request({
            $0.path = prontoAPIClient.versionPath(for: "/devices/registration/\(device.id)")
            $0.httpMethod = .delete
            $0.authentication = .oauth2(.clientCredentials)
        })

        return prontoAPIClient.request(requestObject).map { _ in
            Device.clearCurrent()
            return ()
        }
    }
}

// MARK: - Segments
// --------------------------------------------------------

extension ProntoAPIClientNotificationsModule {
    /// Retrieve all the segments available for this particular application
    ///
    /// - Parameters
    ///   - device: The `Device` to show if device subscribed to the specific segment
    ///
    /// - Returns: `Promise<[Segment]>`
    @discardableResult
    func segments(`for` device: Device) -> Single<[Segment]> {
        let requestObject = Cobalt.Request({
            $0.path = prontoAPIClient.versionPath(for: "/notifications/segments/\(device.id)")
            $0.authentication = .oauth2(.clientCredentials)
        })

        return prontoAPIClient.request(requestObject).map { json -> [Segment] in
            return try json["data"].map(to: [Segment].self)
        }
    }

    /// Promise function to subscribe to a set of segments
    ///
    /// - Parameters:
    ///   - segments: The segments to subscribe to
    ///   - device: The current device
    ///
    /// - Returns: `Promise<Void>`
    @discardableResult
    func subscribe(segments: [Segment], device: Device) -> Single<Void> {
        let encodedSegments = (try? segments.encode()) ?? []
        let requestObject = Cobalt.Request({
            $0.path = prontoAPIClient.versionPath(for: "/notifications/segments")
            $0.httpMethod = .put
            $0.authentication = .oauth2(.clientCredentials)
            $0.parameters = [
                "device_identifier": device.id,
                "segments": encodedSegments
            ]
        })

        return prontoAPIClient.request(requestObject).map { _ in }
    }
}
