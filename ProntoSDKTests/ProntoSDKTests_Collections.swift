//
//  ProntoSDKTests_Collections.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 18/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
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
            let sortBy = SortOrder(key: "id", direction: .ascending)
            collection.list(sortBy: sortBy).then { result in
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
        expect(model.filterValue) == model.id
    }

    private func _testAllModel(_ object: AllTestModel, isFull: Bool) {
        print("-> \(object)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        expect(object.id) == "73E68BA2-8261-4C87-92E5-FF53207A5333"
        expect(object.bool) == true
        expect(object.text?.string(for: ProntoSDK.config.defaultLocale)) == "Text"
        if isFull {
            expect(object.multiText?.string(for: ProntoSDK.config.defaultLocale)).toNot(beNil())
            expect(object.htmlText?.string(for: ProntoSDK.config.defaultLocale)).toNot(beNil())
        } else {
            expect(object.multiText?.string(for: ProntoSDK.config.defaultLocale)).to(beNil())
            expect(object.htmlText?.string(for: ProntoSDK.config.defaultLocale)).to(beNil())

        }
        expect(object.select) == AllTestModel.Select.key1
        expect(object.int) == 5
        expect(dateFormatter.string(from: object.date)) == "2017-01-23"
        expect(object.multiSelect).to(contain([AllTestModel.Select.key2, AllTestModel.Select.key3]))
        expect(object.url?.url()?.absoluteString) == "https://www.pronto.am"
        expect(object.related?.name?.string(for: ProntoSDK.config.defaultLocale)) == "Gerelateerd"
        expect(object.related?.id) == "84B820FD-662A-452F-ACC4-61197AA8CC89"
        expect(object.relations.count) == 3
        expect(object.relations.map { $0.id }).to(contain("1220F2CE-DB8C-425D-B3B4-D9DB0E0A988B"))
        if !isFull {
            expect(object.json).to(beNil())

        } else if let json = object.json {
            expect(json["test"] as? String) == "123"
        } else {
            XCTAssert(false, "Missing jsonString")
        }
    }
    
    func testJSONCollectionMapper() {
        let dic: [String: Any] = [
            "map": [
                "key": "value",
                "array": [ 1, 2, 3 ]
            ],
            "mapArray": [ 5, 6, 7, 8 ]
        ]
        let json = JSON(dic)
        var mapDic: [String: Any] = [:]
        let mapper = ProntoCollectionMapper(json: json)
        do {
            try mapper.map(key: "map", to: &mapDic)
            expect(mapDic["key"] as? String) == "value"
            guard let array = mapDic["array"] as? [Int] else {
                XCTAssert(false, "'array' not found")
                return
            }
            expect(array.count) == 3
            
            var mapArray: [Int] = []
            try mapper.map(key: "mapArray", to: &mapArray)
            expect(mapArray.count) == 4
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testPagination() {
        var pagination = Pagination(offset: 0, limit: 20)
        expect(pagination.previous()).to(beNil())
        pagination.offset = 20
        
        guard let previous = pagination.previous() else {
            XCTAssert(false, "Should get previous")
            return
        }
        expect(previous.offset) == 0
        
        pagination.total = 30
        pagination.offset = 0
        expect(pagination.hasMoreResults) == true
        
        guard let next = pagination.next() else {
            XCTAssert(false, "Should get next")
            return
        }
        expect(next.offset) == 20
        expect(next.hasMoreResults) == false
    }
}
