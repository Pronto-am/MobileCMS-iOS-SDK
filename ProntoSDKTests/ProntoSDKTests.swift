//
//  ProntoSDKTests.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import MockingjayXCTest
import Nimble
import Cobalt
@testable import ProntoSDK

class TestLogger: Cobalt.Logger {
    func verbose(_ items: Any...) {
        print("[VER]", items.map { "\($0)" }.joined(separator: " "))
    }

    func warning(_ items: Any...) {
        print("[WAR]", items.map { "\($0)" }.joined(separator: " "))
    }

    func debug(_ items: Any...) {
        print("[DEB]", items.map { "\($0)" }.joined(separator: " "))
    }

    func success(_ items: Any...) {
        print("[SUC]", items.map { "\($0)" }.joined(separator: " "))
    }

    func error(_ items: Any...) {
        print("[ERR]", items.map { "\($0)" }.joined(separator: " "))
    }

    func log(_ items: Any...) {
        print("[LOG]", items.map { "\($0)" }.joined(separator: " "))
    }

    func info(_ items: Any...) {
        print("[INF]", items.map { "\($0)" }.joined(separator: " "))
    }

    func request(_ items: Any...) {
        if items.count < 3 {
            return
        }
        let stringItems = items.map { "\($0)" }
        print("[REQ]", stringItems.first!, stringItems[1], stringItems[2])
    }

    func response(_ items: Any...) {
        if items.count < 3 {
            return
        }
        let stringItems = items.map { "\($0)" }
        print("[RES]", stringItems.first!, stringItems[1], stringItems[2])
    }
}

class ProntoSDKTests: XCTestCase {
    let apiVersion = "v1"
    let apiClient = ProntoAPIClient.default

    override func setUp() {
        super.setUp()
        URLSessionConfiguration.mockingjaySwizzleDefaultSessionConfiguration()
        AsyncDefaults.Timeout = 5

        ProntoSDK.configure(ProntoConfig({
            $0.clientID = "client_id"
            $0.encryptionKey = "123"
            $0.clientSecret = "client_secret"
            $0.encryptionKey = "encryption_key"
            $0.plugins = [ .notifications, .authentication, .collections, .localization ]
            $0.logger = TestLogger()
        }))
    }
    
    override func tearDown() {
        super.tearDown()
        ProntoSDK.config = nil
        ProntoSDK.reset()
    }
}

extension ProntoSDKTests {
    func mockJSONFile(_ name: String, status: Int = 200) -> Builder {
        let path = Bundle(for: type(of: self)).path(forResource: name, ofType: "json")!
        do {
            let string = try String(contentsOfFile: path)
            let data = string.data(using: .utf8)!
            return jsonData(data, status: status)
        } catch {
            return json([:], status: status)
        }

    }
}
