//
//  PushNotification.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 12/04/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// A representation of a remote push notification's userInfo
public class PushNotification {

    /// The alert title
    private(set) public var title: String?

    /// The message
    private(set) public var body: String?

    /// The unique identifier of the pronto push notification
    public let identifier: String

    /// Click action URL
    private(set) public var clickActionURL: URL?

    init?(userInfo: [AnyHashable: Any]) {
        guard let identifier = userInfo["notificationIdentifier"] as? String else {
            return nil
        }
        self.identifier = identifier

        if let clickAction = userInfo["clickAction"] as? String {
            clickActionURL = URL(string: clickAction)
        }

        if let aps = userInfo["aps"] as? [String: Any],
            let alert = aps["alert"] as? [String: Any] {
            
            self.title = alert["title"] as? String
            self.body = alert["body"] as? String
        }
    }

}
