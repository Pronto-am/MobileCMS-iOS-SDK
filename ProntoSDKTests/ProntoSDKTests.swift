//
//  ProntoSDKTests.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
import RxSwift
import RxCocoa
import Cobalt
@testable import ProntoSDK

class ProntoSDKTests: XCTestCase {
    let apiVersion = "v1"
    let apiClient = ProntoAPIClient.default

    lazy var disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        URLSessionConfiguration.mockingjaySwizzleDefaultSessionConfiguration()
        AsyncDefaults.timeout = .seconds(5)

        ProntoSDK.configure(ProntoConfig({
            $0.clientID = "client_id"
            $0.encryptionKey = "123"
            $0.clientSecret = "client_secret"
            $0.encryptionKey = "encryption_key"
            $0.plugins = [ .notifications, .authentication, .collections, .localization ]
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
