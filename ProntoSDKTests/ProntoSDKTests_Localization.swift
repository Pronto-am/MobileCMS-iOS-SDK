//
//  ProntoSDKTests_Localization.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 23/05/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
import Promises
import Einsteinium
import SwiftyJSON
import CoreLocation

@testable import ProntoSDK

class ProntoSDKTestsLocalization: ProntoSDKTests {
    lazy var localization = ProntoLocalization()

    override func setUp() {
        super.setUp()

        stub(http(.post, uri: "/oauth/v2/token"), mockJSONFile("oauth_token"))
        stub(http(.get, uri: "/api/\(apiVersion)/translations"), mockJSONFile("\(apiVersion)_localization"))

        ProntoSDK.config.defaultLocale = Locale(identifier: "nl_NL")

        localization.setDefaults([
            "welcome_user": [
                "nl": "Standaard welkom",
                "en": "Default welcome"
            ],
            "next_button": [
                "nl": "Standaard volgende",
                "en": "Default next"
            ],
            "keep": [
                "nl": "Behouden",
                "en": "Keep"
            ]
        ])
    }

    func testDefaults() {
        expect(self.localization.get(for: "welcome_user")) == "Standaard welkom"
        expect(self.localization.get(for: "welcome_user", locale: Locale(identifier: "en_US"))) == "Default welcome"
        expect(self.localization.get(for: "welcome_user", locale: Locale(identifier: "it_IT"))) == "Standaard welkom"
        expect(self.localization.get(for: "not_available")).to(beNil())
    }

    func testFetch() {
        let expectation = self.expectation(description: "localization")
        localization.fetch().then {
            expect(self.localization.get(for: "welcome_user")) == "Welkom gebruiker"
            expect(self.localization.get(for: "welcome_user", locale: Locale(identifier: "en_US"))) == "Welcome user!"
            let italianLocale = Locale(identifier: "it_IT")
            expect(self.localization.get(for: "welcome_user", locale: italianLocale)) == "Welkom gebruiker"
            expect(self.localization.get(for: "keep")) == "Behouden"

        }.catch { error in
            XCTAssert(false, "\(error)")
        }.always {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
}
