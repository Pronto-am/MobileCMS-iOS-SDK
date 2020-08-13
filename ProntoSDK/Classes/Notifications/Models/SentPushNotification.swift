//
//  SentPushNotification.swift
//  
//
//  Created by Thomas Roovers on 28/07/2020.
//

import Foundation

public class SentPushNotification: CustomStringConvertible, Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case clickAction = "click_action"
        case clickActionUrl = "click_action_url"
        case clickActionHtml = "click_action_html"
        case clickActionHtmlUrl = "click_action_html_url"
        case sent
    }
    
    public enum ClickAction: Int, Codable {
        case none = 0
        case url = 1
        case html = 2
    }
    
    /// Unique ID
    internal(set) public var id: String = ""

    /// The (localized) title of the notification
    internal(set) public var title: Text!

    /// The (localized) content of the notification
    internal(set) public var content: Text!
    
    internal(set) public var clickAction: Int!
    
    /// A (localized) url which is opened after the user clicks on the notification
    internal(set) public var clickActionUrl: Text!
    
    /// (localized) HTML which is shown after someone opens the notification
    internal(set) public var clickActionHtml: Text!
    
    /// A (localized) static url for the html file stored at Firebase
    internal(set) public var clickActionHtmlUrl: Text!

    /// Is the current device subscribed to that particular segment
    public var sent: Date = Date()

    /// :nodoc:
    public var description: String {
        return "<SentPushNotification> [ id: \(id), title: \(String(describing: title)), sent: \(sent)  ]"
    }

    /// :nodoc:
    public static func == (lhs: SentPushNotification, rhs: SentPushNotification) -> Bool {
        return lhs.id == rhs.id
    }
}
