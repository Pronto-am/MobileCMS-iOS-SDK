//
//  JSON.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 09/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

protocol JSONEncodable {
    var rawJSONString: String { get }
}

extension Array: JSONEncodable { }
extension Dictionary: JSONEncodable { }

extension JSONEncodable {
    var rawJSONString: String {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: JSONSerialization.WritingOptions(rawValue: 0)),
            let theJSONText = String(data: theJSONData, encoding: .utf8) {
            return theJSONText
        }
        return ""
    }
}
