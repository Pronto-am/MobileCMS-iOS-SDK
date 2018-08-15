//
//  ProntoSDKTests_General.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 13/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import SwiftyJSON
import XCTest
import Mockingjay
import Cobalt
import Nimble
import Promises

@testable import ProntoSDK

class ProntoSDKTestsGeneral: ProntoSDKTests {
    override func setUp() {
        super.setUp()
    }

    func testLocalization() {
        let dictionary = [
            "en": "This is a test",
            "nl": "Dit is een test"
        ]

        let json = JSON(dictionary)
        do {
            let text = try json.map(to: Text.self)
            expect(text.string(for: Locale(identifier: "nl_NL"))) == "Dit is een test"
            expect(text.string(for: Locale(identifier: "de_DE"))) == "This is a test"

            let config = ProntoConfig()
            config.clientID = "client_id"
            config.clientSecret = "client_secret"
            config.encryptionKey = "encryption_key"
            config.defaultLocale = Locale(identifier: "nl_NL")
            ProntoSDK.config = nil
            ProntoSDK.configure(config)
            expect(text.string(for: Locale(identifier: "de_DE"))) == "Dit is een test"

            config.defaultLocale = Locale(identifier: "de_DE")
            ProntoSDK.config = nil
            ProntoSDK.configure(config)
            expect(text.string(for: Locale(identifier: "it_IT"))) == ""
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
}
