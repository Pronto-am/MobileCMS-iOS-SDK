//
//  ProntoSDKTests_AppVersion.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 13/02/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import MockingjayXCTest
import Nimble
import Promises
import Einsteinium
import SwiftyJSON
import CoreLocation

@testable import ProntoSDK

class ProntoSDKTestsAppVersion: ProntoSDKTests, ProntoAppUpdateCheckDelegate {
    lazy var updateCheck = ProntoAppUpdateCheck(delegate: self, checkOnAppLaunch: false)

    private var _expectation: XCTestExpectation!

    override func setUp() {
        super.setUp()

        stub(http(.post, uri: "/oauth/v2/token"), mockJSONFile("oauth_token"))

        stub(http(.get, uri: "/bundles/prontomobile/versions.php"), mockJSONFile("app_version"))

        ProntoSDK.config.defaultLocale = Locale(identifier: "nl_NL")
    }

    func testAppVersionCheckNew() {
        _expectation = expectation(description: "app-update")
        updateCheck.check()

        waitForExpectations(timeout: 15, handler: nil)
    }

    func prontoAppUpdateCheck(_ updateCheck: ProntoAppUpdateCheck, newVersion: AppVersion) {
        expect(newVersion.version) == "0.1.0"
        expect(newVersion.url.absoluteString) == "http://google.com"
        expect(newVersion.isRequired) == true
        expect(newVersion.descriptionText?.string(for: ProntoSDK.config.defaultLocale)) == "Dutch tekstje"
        _expectation.fulfill()
    }
}
