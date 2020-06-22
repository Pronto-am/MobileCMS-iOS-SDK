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
import RxSwift
import RxCocoa
import Einsteinium
import SwiftyJSON
import CoreLocation

@testable import ProntoSDK

class ProntoSDKTestsLocalization: ProntoSDKTests {
    lazy var localization = ProntoLocalization()

    let dutchLocale = Locale(identifier: "nl_NL")
    let englishLocale = Locale(identifier: "en_US")
    let italianLocal = Locale(identifier: "it_IT")

    override func setUp() {
        super.setUp()

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
        expect(self.localization.get(for: "welcome_user", locale: self.dutchLocale)) == "Standaard welkom"
        expect(self.localization.get(for: "welcome_user", locale: self.englishLocale)) == "Default welcome"
        expect(self.localization.get(for: "welcome_user", locale: self.italianLocal)) == "Standaard welkom"
        expect(self.localization.get(for: "not_available")).to(beNil())
    }

    func testFetch() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let expectation = self.expectation(description: "localization")
        localization.fetch().subscribe { [unowned self] event in
            switch event {
            case .success:
                expect(self.localization.get(for: "welcome_user", locale: self.dutchLocale)) == "Welkom gebruiker"
                expect(self.localization.get(for: "welcome_user", locale: self.englishLocale)) == "Welcome user!"
                expect(self.localization.get(for: "welcome_user", locale: self.italianLocal)) == "Welkom gebruiker"
                expect(self.localization.get(for: "keep", locale: self.dutchLocale)) == "Behouden"
            case .error(let error):
                XCTAssert(false, "\(error)")
            }
            self.removeStub(authStub)
            expectation.fulfill()
        }.disposed(by: disposeBag)
        waitForExpectations(timeout: 15, handler: nil)
    }
}
