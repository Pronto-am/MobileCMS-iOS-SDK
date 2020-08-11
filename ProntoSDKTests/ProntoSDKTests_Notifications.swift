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
import RxSwift
import RxCocoa

@testable import ProntoSDK

class ProntoSDKTestsNotifications: ProntoSDKTests {
    lazy var prontoNotifications = ProntoNotifications()

    override func setUp() {
        super.setUp()
        ProntoSDK.config.defaultLocale = Locale(identifier: "en_US")
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
            self.apiClient.notifications.registerDevice(deviceToken: "123").subscribe { event in
                switch event {
                case .success(let device):
                    expect(device.id) == "84cfe80f-8d23-43f7-9016-53dc0e23860b"
                    guard let current = Device.current else {
                        XCTAssert(false, "Current device is empty")
                        return
                    }
                    expect(current) == device
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(registerStub)
                self.removeStub(authStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testUnregister() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let unregisterStub = stub(http(.delete, uri: "/api/\(apiVersion)/devices/registration/{device_id}"),
                                  mockJSONFile("\(apiVersion)_notifications-devices-unregister"))

        waitUntil { done in
            self.prontoNotifications.unregister(device: Device.mock()).subscribe { event in
                switch event {
                case .success:
                    break
                case .error(let error):
                    XCTAssert(false, "\(error)")

                }
                self.removeStub(unregisterStub)
                self.removeStub(authStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testSegments() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let segmentsStub = stub(http(.get, uri: "/api/\(apiVersion)/notifications/segments/{device_id}"),
                                mockJSONFile("\(apiVersion)_notifications-segments"))

        waitUntil { done in
            self.prontoNotifications.segments(for: Device.mock()).subscribe { event in
                switch event {
                case .success(let segments):
                    expect(segments.count) == 2
                    expect(segments.filter { $0.isSubscribed }.count) == 1
                    if let segment = segments.first {
                        expect(segment.name?.string(for: ProntoSDK.config.defaultLocale)) == "Segment one"
                    }
                    if let segment = segments.last {
                        expect(segment.name?.string(for: ProntoSDK.config.defaultLocale)) == "Segment two"
                    }
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(segmentsStub)
                self.removeStub(authStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testSentNotifications() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let notificationsStub = stub(http(.get, uri: "/api/\(apiVersion)/notifications/{device_id}"),
                                mockJSONFile("\(apiVersion)_notifications"))

        waitUntil { done in
            self.prontoNotifications.getSent(to: Device.mock()).subscribe { event in
                switch event {
                case .success(let notifications):
                    expect(notifications.count) == 2
                    if let notification = notifications.first {
                        expect(notification.name?.string(for: ProntoSDK.config.defaultLocale)) == "Segment one"
                    }
                    if let notification = notifications.last {
                        expect(notification.name?.string(for: ProntoSDK.config.defaultLocale)) == "Segment two"
                    }
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(notificationsStub)
                self.removeStub(authStub)
                done()
            }.disposed(by: self.disposeBag)
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
            self.prontoNotifications.update(segments: segments, device: Device.mock()).subscribe { event in
                switch event {
                case .error(let error):
                    XCTAssert(false, "\(error)")
                case .success:
                    break
                }
                self.removeStub(segmentsSubscribeStub)
                self.removeStub(authStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testWebViewController() {
        let viewController = WebviewController()
        viewController.viewDidLoad()
        let request = URLRequest(url: URL(string: "https://www.pronto.am")!)
        viewController.load(urlRequest: request)
        expect(viewController.loadingIndicator.isAnimating).toEventually(equal(false), timeout: .seconds(60))
    }

    func testWebViewControllerError() {
        let viewController = WebviewController()
        viewController.viewDidLoad()
        let request = URLRequest(url: URL(string: "https://www.somenoneexisting.domain.pronto")!)
        viewController.load(urlRequest: request)
        expect(viewController.loadingIndicator.isAnimating).toEventually(equal(false), timeout: .seconds(60))
        expect(viewController.webView.isHidden).toEventually(equal(true), timeout: .seconds(60))
        expect(viewController.errorLabel.isHidden).toEventually(equal(false), timeout: .seconds(60))
    }
}
