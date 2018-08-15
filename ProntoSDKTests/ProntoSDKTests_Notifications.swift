//
//  ProntoSDKTests_Notifications.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 07/03/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
import Promises

@testable import ProntoSDK

class ProntoSDKTestsNotifications: ProntoSDKTests {
    override func setUp() {
        super.setUp()
    }

    func testRegisterDevice() {
        Device.clearCurrent()

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let registerStub = stub(http(.post, uri: "/api/\(apiVersion)/devices/registration"),
                                mockJSONFile("\(apiVersion)_notifications-register-device"))
        _ = apiClient.notifications.registerDevice(deviceToken: "123")
        _ = apiClient.notifications.registerDevice(deviceToken: "123")
        waitUntil { done in
            self.apiClient.notifications.registerDevice(deviceToken: "123").then { device in
                expect(device.id) == "84cfe80f-8d23-43f7-9016-53dc0e23860b"
                guard let current = Device.current else {
                    XCTAssert(false, "Current device is empty")
                    return
                }
                expect(current) == device
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(registerStub)
                self.removeStub(authStub)
                done()
            }
        }
    }

    func testUnregister() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let unregisterStub = stub(http(.delete, uri: "/api/\(apiVersion)/devices/registration/{device_id}"),
                              mockJSONFile("\(apiVersion)_notifications-devices-unregister"))

        waitUntil { done in
            self.apiClient.notifications.unregister(device: Device.mock())
            .catch { error in
                XCTAssert(false, "\(error)")

            }.always {
                self.removeStub(unregisterStub)
                self.removeStub(authStub)
                done()
            }
        }
    }

    func testSegments() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let segmentsStub = stub(http(.get, uri: "/api/\(apiVersion)/notifications/segments/{device_id}"),
                                mockJSONFile("\(apiVersion)_notifications-segments"))

        waitUntil { done in
            self.apiClient.notifications.segments(for: Device.mock()).then { segments in
                expect(segments.count) == 2
                expect(segments.filter { $0.isSubscribed }.count) == 1
                if let segment = segments.first {
                    expect(segment.name?.string()) == "Segment one"
                }
                if let segment = segments.last {
                    expect(segment.name?.string()) == "Segment two"
                }
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(segmentsStub)
                self.removeStub(authStub)
                done()
            }
        }
    }

    func testSubscribeSegments() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let segmentsSubscribeStub = stub(http(.put, uri: "/api/\(apiVersion)/notifications/segments"),
                                mockJSONFile("\(apiVersion)_notifications-segments-subscribe"))

        let segments: [Segment] = [(1, true), (2, false)].map { tuple in
            let segment = Segment()
            segment.id = tuple.0
            segment.isSubscribed = tuple.1
            return segment
        }

        waitUntil { done in
            self.apiClient.notifications.subscribe(segments: segments, device: Device.mock()).catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(segmentsSubscribeStub)
                self.removeStub(authStub)
                done()
            }
        }
    }

    func testWebViewController() {
        let viewController = WebviewController()
        viewController.viewDidLoad()
        let request = URLRequest(url: URL(string: "https://www.pronto.am")!)
        viewController.load(urlRequest: request)
        expect(viewController.loadingIndicator.isAnimating).toEventually(equal(false), timeout: 60)
    }

    func testWebViewControllerError() {
        let viewController = WebviewController()
        viewController.viewDidLoad()
        let request = URLRequest(url: URL(string: "https://www.somenoneexisting.domain.pronto")!)
        viewController.load(urlRequest: request)
        expect(viewController.loadingIndicator.isAnimating).toEventually(equal(false), timeout: 60)
        expect(viewController.webView.isHidden).toEventually(equal(true), timeout: 60)
        expect(viewController.errorLabel.isHidden).toEventually(equal(false), timeout: 60)
    }
}
