//
//  ProntoNotifications.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import UIKit
import Einsteinium
import UserNotifications
import KeychainAccess
import SwiftyJSON

/// Notifications error
public enum ProntoNotificationsError: Error {

    /// Not authorized
    case notAuthorized

    /// Any other error
    case underlying(Error)
}

/// Helper class to handle all the notifications logic
public class ProntoNotifications: PluginBase {

    fileprivate struct Constants {
        static let didRegisterRemoteNotificationsKey = "didRegisterRemoteNotificationsKey"
        static let additionalDataKeychainKey = "additionalDataKeychainKey"
    }

    var requiredPlugins: [ProntoPlugin] {
        return [ .notifications ]
    }

    private var _storeInKeyChain = false

    /// Set additional device data.
    /// Will be passed along a 'register' of 'signin' call.
    public var additionalDeviceData: [String: Any] = [:] {
        didSet {
            if !_storeInKeyChain {
                return
            }
            let string = additionalDeviceData.rawJSONString
            KeychainHelper.store(string: string, for: Constants.additionalDataKeychainKey)
        }
    }

    /// The ProntoNotificationsDelegate delegate (optional).
    public weak var delegate: ProntoNotificationsDelegate?
    
    /// Default constructor
    private weak var apiClient: ProntoAPIClient!

    /// Default contructor
    public convenience init() {
        self.init(apiClient: ProntoAPIClient.default)
    }

    init(apiClient: ProntoAPIClient) {
        self.apiClient = apiClient
        checkPlugin()
        defer {
            _storeInKeyChain = true
        }
        guard let string = KeychainHelper.string(for: Constants.additionalDataKeychainKey),
            let dictionary = JSON(parseJSON: string).dictionaryObject else {
            return
        }
        additionalDeviceData = dictionary
    }

    func configure() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_clear),
                                               name: ProntoSDK.Constant.clearNotificationName,
                                               object: nil)

        ApplicationWatcher.shared.add(plugin: .notifications) { apiClient in
            guard let currentDevice = Device.current else {
                return
            }
            
            guard let string = KeychainHelper.string(for: Constants.additionalDataKeychainKey),
                let dictionary = JSON(parseJSON: string).dictionaryObject else {
                    return
            }

            apiClient.notifications.signIn(device: currentDevice, additionalData: dictionary)
        }
    }

    @objc
    private func _clear() {
       KeychainHelper.remove(for: Constants.additionalDataKeychainKey)
    }

    /// Register the device to pronto.am' API
    ///
    /// **Example:**
    ///
    ///     let prontoNotifications = ProntoNotifications()
    ///
    ///     func application(_ application: UIApplication,
    ///                      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ///         prontoNotifications.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    ///     }
    ///
    /// - Parameters:
    ///    - additionalData: `[String: Any]?` (Optional)
    ///    - handler: `((Error?) -> Void)?` (Optional)
    public func registerForRemoteNotifications(additionalData: [String: Any]? = nil,
                                               _ handler: ((ProntoNotificationsError?) -> Void)? = nil) {
        if additionalData != nil {
            additionalDeviceData = additionalData!
        }
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    let notification = Notification.Name(rawValue: Constants.didRegisterRemoteNotificationsKey)
                    var observer: NSObjectProtocol!
                    observer = NotificationCenter.default
                        .addObserver(forName: notification,
                                     object: nil,
                                     queue: nil) { notification in
                                        NotificationCenter.default.removeObserver(observer)
                                        handler?(notification.object as? ProntoNotificationsError)
                        }
                    
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    handler?(.notAuthorized)
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ProntoNotifications {
    /// Handle an incoming notification
    /// This must be called from the app delegate's `didReceiveRemoteNotification`
    ///
    /// **Example:**
    ///
    ///     let prontoNotifications = ProntoNotifications()
    ///
    ///     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    ///                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    ///         prontoNotifications.handleNotification(userInfo: userInfo,
    ///                                                        fetchCompletionHandler: completionHandler)
    ///     }
    ///
    /// - Parameters:
    ///   - userInfo: `[AnyHashable: Any]` The userinfo of the remote push notification
    ///   - fetchCompletionHandler: `(UIBackgroundFetchResult) -> Void` Called when the handling
    ///                             of the notification is finished.
    public func handleNotification(userInfo: [AnyHashable: Any],
                                   fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        ProntoLogger.log("Remote notification payload: " + userInfo.rawJSONString)

        guard let pushNotification = PushNotification(userInfo: userInfo) else {
            ProntoLogger.warning("UserInfo: notificationIdentifier is not set")
            fetchCompletionHandler(.failed)
            return
        }

        guard let device = Device.current else {
            ProntoLogger.warning("Device.current is not set")
            fetchCompletionHandler(.failed)
            return
        }

        switch UIApplication.shared.applicationState {
        // App is in foreground
        case .active:
            ProntoLogger.info("Notification received when the app was active")
            delegate?.prontoNotifications(self, didReceivePushNotification: pushNotification)

            apiClient.notifications.notificationOpened(
                notificationIdentifier: pushNotification.identifier,
                device: device)
                .then {
                    fetchCompletionHandler(.newData)
                }.catch { _ in
                    fetchCompletionHandler(.failed)
                }

        // App launched through tapping on the push notification
        case .inactive:
            apiClient.notifications.notificationOpened(
                notificationIdentifier: pushNotification.identifier,
                device: device)
            .then {
                fetchCompletionHandler(.newData)
            }.catch { _ in
                fetchCompletionHandler(.failed)
            }

            if let url = pushNotification.clickActionURL {
                let webviewController = _presentWebViewController(withURL: url)
                webviewController.title = pushNotification.title
            }

        // Push notification received, when the app is in the background
        case .background:
            // Disable 'notifications received' logging, because Android (since O) doesn't support this
//            apiClient.notifications.notificationReceived(
//                notificationIdentifier: pushNotification.identifier,
//                device: device)
//            .then {
//                fetchCompletionHandler(.newData)
//            }.catch { _ in
//                fetchCompletionHandler(.failed)
//            }
            fetchCompletionHandler(.newData)
        }
    }

    @discardableResult
    private func _presentWebViewController(withURL url: URL) -> WebviewController {
        let webViewController = WebviewController()
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = true
        var urlRequest = URLRequest(url: url)
        let base64 = apiClient.base64DecodedAuthorization
        urlRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        webViewController.load(urlRequest: urlRequest)
        
        if var viewController = UIApplication.shared.delegate?.window??.rootViewController {
            while true {
                if let pres = viewController.presentedViewController, !pres.isBeingDismissed {
                    viewController = pres
                    continue
                }
                break
            }
            viewController.present(navigationController, animated: true, completion: nil)
        }
        return webViewController
    }

    /// When the app succesfully registered to the apns server, call this method to let pronto register the device.
    ///
    /// **Example:**
    ///
    /// ```
    /// func application(_ application: UIApplication,
    ///         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    /// ```
    ///
    /// - Parameters:
    ///   - deviceToken: `Data`
    ///   - sandbox: Is the registration done in a sandbox environmnet (aka #DEBUG) (Default = false)
    public func didRegisterForRemoteNotifications(deviceToken: Data, sandbox: Bool = false) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        let notification = Notification.Name(rawValue: Constants.didRegisterRemoteNotificationsKey)
        
        // No current device set, register with pronto
        guard let currentDevice = Device.current else {
            apiClient.notifications.registerDevice(deviceToken: deviceTokenString,
                                                                 sandbox: sandbox,
                                                                 additionalData: additionalDeviceData)
            .then { _ in
                ProntoLogger.success("Device succesfully registered")
                NotificationCenter.default.post(name: notification, object: nil)
            }.catch { error in
                ProntoLogger.error("Error registering device: \(error)")
                NotificationCenter.default.post(name: notification, object: ProntoNotificationsError.underlying(error))
            }
            return
        }

        // If the deviceToken changed from the current device, update through 'sign in'
        if currentDevice.deviceToken != deviceTokenString {
            currentDevice.deviceToken = deviceTokenString
            currentDevice.store()
            apiClient.notifications.signIn(device: currentDevice, additionalData: additionalDeviceData)
        }

        NotificationCenter.default.post(name: notification, object: nil)
    }

    /// When the app failsto register to the apns server.
    ///
    /// **Example:**
    ///
    /// ```
    ///  let prontoNotifications = ProntoNotifications()
    ////
    ///  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    ///      prontoNotifications.didFailToRegisterForRemoteNotifications(with: error)
    ///  }
    /// ```
    ///
    /// - Parameters:
    ///   - error: `Error`
    public func didFailToRegisterForRemoteNotifications(with error: Error) {
        ProntoLogger.error("Error registering device: \(error)")
        let notification = Notification.Name(rawValue: Constants.didRegisterRemoteNotificationsKey)
        NotificationCenter.default.post(name: notification, object: ProntoNotificationsError.underlying(error))
    }
}
