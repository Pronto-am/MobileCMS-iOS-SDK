//
//  Encodable.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 27/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Encodable {
    func encode() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)

        guard let dic = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw ProntoError.mapping
        }

        return dic
    }
}

extension Array where Element: Encodable {
    func encode() throws -> [[String: Any]] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)

        guard let array = try JSONSerialization.jsonObject(with: data,
                                                           options: .allowFragments) as? [[String: Any]] else {
                                                            throw ProntoError.mapping
        }

        return array
    }
}
