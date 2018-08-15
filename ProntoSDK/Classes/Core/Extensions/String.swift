//
//  String.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 09/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

extension String {
    static func random(size: Int) -> String {
        let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let charactersArray: [Character] = Array(charactersString)

        return Array(0..<size).map { _ in
            return String(charactersArray[Int(arc4random_uniform(UInt32(charactersArray.count)))])
        }.joined()
    }

    var isValidEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]" +
                "(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}" +
                "[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        } catch {
            return false
        }
    }
}
