//
//  ProntoSDKTests_Collections.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
import Promises
import Einsteinium
import SwiftyJSON
import CoreLocation

@testable import ProntoSDK

class ProntoSDKTestsCollections: ProntoSDKTests {

    override func setUp() {
        super.setUp()
        ProntoSDK.config.defaultLocale = Locale(identifier: "nl_NL")
    }

    func testCollectionsList() {

        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let collectionsStub = stub(http(.get, uri: "/api/\(apiVersion)/collections/{appVersion}/alles"),
                               mockJSONFile("\(apiVersion)_collections_all"))

        waitUntil { done in
            let collection = ProntoCollection<AllTestModel>()
            collection.list().then { result in
                expect(result.pagination.total) == 1
                expect(result.pagination.hasMoreResults) == false
                expect(result.items.count) == 1
                guard let object = result.items.first else {
                    XCTAssert(false, "No objects")
                    return
                }
                self._testAllModel(object, isFull: false)
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(loginStub)
                self.removeStub(collectionsStub)
                done()
            }
        }
    }

    func testCollectionsGet() {

        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let collectionsStub = stub(http(.get, uri: "/api/\(apiVersion)/collections/{appVersion}/alles/{identifier}"),
                                   mockJSONFile("\(apiVersion)_collections_all_get"))

        waitUntil { done in
            let collection = ProntoCollection<AllTestModel>()
            collection.get(id: "73E68BA2-8261-4C87-92E5-FF53207A5333").then { object in
                self._testAllModel(object, isFull: true)
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(loginStub)
                self.removeStub(collectionsStub)
                done()
            }
        }
    }

    func testCollectionFilterable() {
        expect(1.filterValue) == "1"
        expect(false.filterValue) == "false"
        expect((5.5).filterValue) == "5.5"
        let model = AllTestModel()
        model.id = "5A53D389-B444-4659-9F15-1B5DE1379027"
        expect(model.filterValue) == model.id
    }

    private func _testAllModel(_ object: AllTestModel, isFull: Bool) {
        print("-> \(object)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        expect(object.id) == "73E68BA2-8261-4C87-92E5-FF53207A5333"
        expect(object.bool) == true
        expect(object.text?.string()) == "Text"
        if isFull {
            expect(object.multiText?.string()).toNot(beNil())
            expect(object.htmlText?.string()).toNot(beNil())
        } else {
            expect(object.multiText?.string()).to(beNil())
            expect(object.htmlText?.string()).to(beNil())

        }
        expect(object.select) == AllTestModel.Select.key1
        expect(object.int) == 5
        expect(dateFormatter.string(from: object.date)) == "2017-01-23"
        expect(object.multiSelect).to(contain([AllTestModel.Select.key2, AllTestModel.Select.key3]))
        expect(object.url?.url()?.absoluteString) == "https://www.pronto.am"
        expect(object.related?.name?.string()) == "Gerelateerd"
        expect(object.related?.id) == "84B820FD-662A-452F-ACC4-61197AA8CC89"
        expect(object.relations.count) == 3
        if !isFull {
            expect(object.json).to(beNil())

        } else if let json = object.json {
            expect(json["test"] as? String) == "123"
        } else {
            XCTAssert(false, "Missing jsonString")
        }
    }
}
