//
//  ProntoSDKTests_User.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 29/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import MockingjayXCTest
import Nimble
import Promises
import Einsteinium

@testable import ProntoSDK

class ProntoSDKTestUser: ProntoSDKTests {
    lazy var prontoAuthentication: ProntoAuthentication = {
        let prontoAuth = ProntoAuthentication(apiClient: apiClient)
        return prontoAuth
    }()
    
    func testRegisterUser() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let registerStub = stub(http(.post, uri: "/api/\(apiVersion)/users/app/registration"),
                               mockJSONFile("\(apiVersion)_userprofile"))

        waitUntil { [unowned self] done in
            let user = User.mock()
            self.prontoAuthentication.register(user: user, password: "1234").then { user in
                ProntoSDKTestsAuthentication.userExpectTest(user)
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(authStub)
                self.removeStub(registerStub)
                done()
            }
        }
    }

    func testRegisterUserAlready() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let registerStub = stub(http(.post, uri: "/api/\(apiVersion)/users/app/registration"),
                                mockJSONFile("\(apiVersion)_registeralready", status: 422))

        waitUntil { done in
            let user = User.mock()

            self.prontoAuthentication.register(user: user, password: "1234").then { _ in
                XCTAssert(false, "Should not reach this")
            }.catch { error in
                XCTAssert(error == ProntoError.alreadyRegistered, "Expects ProntoError.alreadyRegistered, got \(error)")
            }.always {
                self.removeStub(authStub)
                self.removeStub(registerStub)
                done()
            }
        }
    }

    func testUnregister() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               mockJSONFile("\(apiVersion)_userprofile"))
        let unregisterStub = stub(http(.delete, uri: "/api/\(apiVersion)/users/app/registration/{id}"),
                                mockJSONFile("\(apiVersion)_userprofile"))
        
        waitUntil { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").then { user -> Promise<Void> in
                return self.prontoAuthentication.unregister(user: user)
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                expect(self.prontoAuthentication.currentUser).to(beNil())
                self.removeStub(profileStub)
                self.removeStub(authStub)
                self.removeStub(unregisterStub)
                done()
            }
        }
        
    }
    
    func testAnonymouseUser() {
        waitUntil { [unowned self] done in
            self.apiClient.user.profile().then { _ in
                XCTAssert(false, "Should not reach this")

            }.always {
                expect(self.prontoAuthentication.currentUser).to(beNil())
                done()
            }
        }
    }

    func testUpdateUser() {

        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let profileUpdateStub = stub(http(.put, uri: "/api/\(apiVersion)/users/app/profile"),
                               mockJSONFile("\(apiVersion)_userprofile"))
        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               mockJSONFile("\(apiVersion)_userprofile"))

        waitUntil { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").then { _ -> Promise<User> in
                let user = User.mock()
                return self.apiClient.user.update(user)
            }.then { user in
                ProntoSDKTestsAuthentication.userExpectTest(user)
            }.catch { error in
                XCTAssert(false, "\(error)")
            }.always {
                self.removeStub(authStub)
                self.removeStub(profileStub)
                self.removeStub(profileUpdateStub)
                done()
            }
        }
    }
}
