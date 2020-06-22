//
//  ProntoSDKTests_User.swift
//  ProntoSDKTests
//
//  Created by Bas van Kuijck on 29/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
import RxSwift
import RxCocoa
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
            self.prontoAuthentication.register(user: user, password: "1234").subscribe { event in
                switch event {
                case .success(let user):
                    ProntoSDKTestsAuthentication.userExpectTest(user)
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(authStub)
                self.removeStub(registerStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testRegisterUserAlready() {
        let authStub = stub(http(.post, uri: "/oauth/v2/token"),
                            mockJSONFile("oauth_token"))
        let registerStub = stub(http(.post, uri: "/api/\(apiVersion)/users/app/registration"),
                                mockJSONFile("\(apiVersion)_registeralready", status: 422))

        waitUntil { done in
            let user = User.mock()

            self.prontoAuthentication.register(user: user, password: "1234").subscribe { event in
                switch event {
                case .success:
                    XCTAssert(false, "Should not reach this")
                case .error(let error):
                    XCTAssert(error == ProntoError.alreadyRegistered,
                              "Expects ProntoError.alreadyRegistered, got \(error)")
                }
                self.removeStub(authStub)
                self.removeStub(registerStub)
                done()
            }.disposed(by: self.disposeBag)
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
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234")
            .flatMap { [unowned self] user -> Single<Void> in
                return self.prontoAuthentication.unregister(user: user)
            }.subscribe { event in
                switch event {
                case .success:
                    break
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                expect(self.prontoAuthentication.currentUser).to(beNil())
                self.removeStub(profileStub)
                self.removeStub(authStub)
                self.removeStub(unregisterStub)
                done()
            }.disposed(by: self.disposeBag)
        }
        
    }
    
    func testAnonymouseUser() {
        waitUntil { [unowned self] done in
            self.apiClient.user.profile().subscribe { event in
                switch event {
                case .success:
                    XCTAssert(false, "Should not reach this")
                case .error:
                    break
                }
                expect(self.prontoAuthentication.currentUser).to(beNil())
                done()
            }.disposed(by: self.disposeBag)
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
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234")
            .flatMap { [unowned self] _ -> Single<User> in
                let user = User.mock()
                return self.apiClient.user.update(user)
            }.subscribe { event in
                switch event {
                case .success(let user):
                    ProntoSDKTestsAuthentication.userExpectTest(user)
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(authStub)
                self.removeStub(profileStub)
                self.removeStub(profileUpdateStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }
}
