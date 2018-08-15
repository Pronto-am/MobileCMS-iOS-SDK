//
//  ProntoNotificationsDelegate.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 27/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// The delegate for ProntoNotifications
public protocol ProntoNotificationsDelegate: class {
    /// Called when the app is in the foreground and a remote push notification is received.
    /// That way you can trigger a custom dialog or anything like that.
    ///
    /// - Parameters:
    ///   - prontoNotifications: `ProntoNotifications`
    ///   - pushNotification: `PushNotification`
    func prontoNotifications(_ prontoNotifications: ProntoNotifications,
                             didReceivePushNotification pushNotification: PushNotification)
}
