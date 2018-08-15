//
//  ProntoSDKTests_Authentication.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 28/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
import Promises
import Einsteinium

@testable import ProntoSDK

class ProntoSDKTestsAuthentication: ProntoSDKTests {
    lazy var prontoAuthentication = ProntoAuthentication()
    override func setUp() {
        super.setUp()
    }

    func testAccessToken() {
        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               mockJSONFile("\(apiVersion)_userprofile"))

        waitUntil { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").then { _ in

            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(loginStub)
                self.removeStub(profileStub)
                done()
            }
        }
    }

    func testRefreshAccessToken() {

        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                                    mockJSONFile("\(apiVersion)_userprofile"))
        waitUntil(timeout: 10) { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").then { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {

                    self.apiClient.user.profile().then { user in
                        ProntoSDKTestsAuthentication.userExpectTest(user)
                    }.catch { error in
                        XCTAssert(false, "\(error)")
                    }.always {
                        self.removeStub(loginStub)
                        self.removeStub(profileStub)
                        done()
                    }

                }
            }.catch { error in
                XCTAssert(false, "\(error)")
                self.removeStub(loginStub)
                self.removeStub(profileStub)
                done()
            }
        }
    }

    static func userExpectTest(_ user: User) {
        expect(user.email) == "bas@e-sites.nl"
        expect(user.firstName) == "Bas"
        expect(user.lastName) == "van Kuijck"
        expect(user.isActivated) == true
        expect(user.id) == "6b87fcda-7b7f-11e8-bc93-005056010246"
        expect(user.extraData?.keys).to(contain("gender"))
        expect(user.extraData?["gender"]) == "male"
    }

    func testRefreshAccessToken2() {
        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let profileStubSuccess = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                                      mockJSONFile("\(apiVersion)_userprofile"))

        var profileStubSuccess2: Stub!

        waitUntil(timeout: 5) { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").then { _ in
                self.removeStub(profileStubSuccess)
                let profileStubFailed = self.stub(http(.get, uri: "/api/\(self.apiVersion)/users/app/profile"),
                                                  delay: 2,
                                                  self.mockJSONFile("accesstoken_expired", status: 400))
                self.apiClient.user.profile().then { user in
                    ProntoSDKTestsAuthentication.userExpectTest(user)
                }.catch { error in
                    XCTAssert(false, "\(error)")
                }.always {
                    self.removeStub(loginStub)
                    self.removeStub(profileStubSuccess2)
                    done()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.removeStub(profileStubFailed)
                    profileStubSuccess2 = self.stub(http(.get,
                                                         uri: "/api/\(self.apiVersion)/users/app/profile"),
                                                    self.mockJSONFile("\(self.apiVersion)_userprofile"))
                }
            }.catch { error in
                XCTAssert(false, "\(error)")
                self.removeStub(loginStub)
                self.removeStub(profileStubSuccess)
                done()
            }
        }
    }

    func testDoubleAuthentication() {

        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             delay: 1,
                             mockJSONFile("oauth_token"))

        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               delay: 1,
                               mockJSONFile("\(apiVersion)_userprofile"))
        waitUntil(timeout: 10) { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").then { _ in
                print("... waiting ...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.apiClient.user.profile().then { _ in

                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.apiClient.user.profile().then { _ in

                        }.catch { error in
                            XCTAssert(false, "\(error)")
                        }.always {
                            self.removeStub(profileStub)
                            done()
                        }
                    }
                }
            }.catch { error in
                XCTAssert(false, "\(error)")
                self.removeStub(loginStub)
                self.removeStub(profileStub)
                done()
            }
        }
    }
}
