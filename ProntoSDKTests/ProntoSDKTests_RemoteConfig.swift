//
//  ProntoSDKTests_RemoteConfig.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 24/10/2019.
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

class ProntoSDKTestsRemoteConfig: ProntoSDKTests {
    lazy var remoteConfig = ProntoRemoteConfig()

    override func setUp() {
        super.setUp()

        stub(http(.get, uri: "/api/\(apiVersion)/config"), mockJSONFile("\(apiVersion)_remoteconfig"))
    }

    func testFetch() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"), mockJSONFile("oauth_token"))
        let expectation = self.expectation(description: "remote-config")
        remoteConfig.fetch().then { items in
            expect(items.count) == 5

        }.catch { error in
            XCTAssert(false, "\(error)")
        }.always {
            self.removeStub(authStub)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15, handler: nil)
    }

    func testCache() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"), mockJSONFile("oauth_token"))
        let expectation = self.expectation(description: "remote-config")
        remoteConfig.fetch().then { items in
            let all = self.remoteConfig.items
            expect(items.count) == all.count

            let newRemoteConfig = ProntoRemoteConfig()
            expect(newRemoteConfig.items.count) == items.count

        }.catch { error in
            XCTAssert(false, "\(error)")
        }.always {
            self.removeStub(authStub)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15, handler: nil)
    }

    func testGetSingleItems() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"), mockJSONFile("oauth_token"))
        let expectation = self.expectation(description: "remote-config")
        remoteConfig.fetch().then { _ in
            expect(self.remoteConfig.get("string_example")?.stringValue) == "hello 123"
            expect(self.remoteConfig.get("bool_key")?.boolValue) == true
            expect(self.remoteConfig.get("pronto_does_rule")?.integerValue) == 12
            expect(self.remoteConfig["epic_config"]?.dictionaryValue?["client_id"]) == "123344555a"

        }.catch { error in
            XCTAssert(false, "\(error)")
        }.always {
            self.removeStub(authStub)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
}
