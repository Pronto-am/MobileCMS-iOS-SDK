//
//  DateFormatting.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

class DateFormatting {
    static var iso8601DateTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        return dateFormatter
    }

    static var iso8601DateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}
