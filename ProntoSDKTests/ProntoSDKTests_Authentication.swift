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
import RxSwift
import RxCocoa
import Einsteinium

@testable import ProntoSDK

class ProntoSDKTestsAuthentication: ProntoSDKTests {
    lazy var prontoAuthentication = ProntoAuthentication()
    override func setUp() {
        super.setUp()
    }

    func testAccessToken() {
        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_invalidgrant", status: 400))

        waitUntil { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "invalid_password")
            .subscribe { [unowned self] event in
                switch event {
                case .success(let user):
                    XCTAssert(false, "Expected to fail, got \(user)")
                case .error(let error):
                    guard let prontoError = error as? ProntoError else {
                        XCTAssert(false, "Expected error to be ProntoError, got \(error)")
                        return
                    }
                    expect(prontoError) == ProntoError.invalidCredentials
                }
                self.removeStub(loginStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testInvalidGrant() {
        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               mockJSONFile("\(apiVersion)_userprofile"))

        waitUntil { [unowned self] done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").subscribe { event in
                switch event {
                case .success(let user):
                    guard let currentUser = self.prontoAuthentication.currentUser else {
                        XCTAssert(false, "Expected to have 'currentUser'")
                        return
                    }
                    expect(currentUser.id) == user.id
                    expect(currentUser.email) == user.email
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(loginStub)
                self.removeStub(profileStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testRefreshAccessToken() {

        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               mockJSONFile("\(apiVersion)_userprofile"))
        waitUntil(timeout: .seconds(10)) { [unowned self] done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234")
            .flatMap { _ in
                return self.prontoAuthentication.getProfile()
            }.subscribe { event in
                switch event {
                case .success(let user):
                    ProntoSDKTestsAuthentication.userExpectTest(user)
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(loginStub)
                self.removeStub(profileStub)
                done()
            }.disposed(by: self.disposeBag)
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

    func testPasswordReset() {

        let oauthStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let passwordResetStub = stub(http(.post, uri: "/api/\(apiVersion)/users/app/password/reset"),
                                     mockJSONFile("\(apiVersion)_user_passwordreset"))

        waitUntil(timeout: .seconds(5)) { [unowned self] done in
            self.prontoAuthentication.passwordResetRequest(email: "bas@e-sites.nl").subscribe { event in
                switch event {
                case .success:
                    break
                case .error(let error):
                    XCTAssert(false, "\(error)")
                }
                self.removeStub(oauthStub)
                self.removeStub(passwordResetStub)
                done()
            }.disposed(by: self.disposeBag)
        }
    }

    func testRefreshAccessToken2() {
        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             mockJSONFile("oauth_token"))

        let profileStubSuccess = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                                      mockJSONFile("\(apiVersion)_userprofile"))

        var profileStubSuccess2: Stub!

        waitUntil(timeout: .seconds(5)) { done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").subscribe { event in
                switch event {
                case .success:
                    self.removeStub(profileStubSuccess)
                    let profileStubFailed = self.stub(http(.get, uri: "/api/\(self.apiVersion)/users/app/profile"),
                                                      delay: 2,
                                                      self.mockJSONFile("accesstoken_expired", status: 400))

                    self.prontoAuthentication.getProfile().subscribe { event in
                        switch event {
                        case .success(let user):
                            ProntoSDKTestsAuthentication.userExpectTest(user)
                        case .error(let error):
                            XCTAssert(false, "\(error)")
                        }
                        self.removeStub(loginStub)
                        self.removeStub(profileStubSuccess2)
                        done()
                    }.disposed(by: self.disposeBag)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.removeStub(profileStubFailed)
                        profileStubSuccess2 = self.stub(http(.get,
                                                             uri: "/api/\(self.apiVersion)/users/app/profile"),
                                                        self.mockJSONFile("\(self.apiVersion)_userprofile"))
                    }
                case .error(let error):
                    XCTAssert(false, "\(error)")
                    self.removeStub(loginStub)
                    self.removeStub(profileStubSuccess)
                    done()
                }
            }.disposed(by: self.disposeBag)
        }
    }

    func testDoubleAuthentication() {

        let loginStub = stub(http(.post, uri: "/oauth/v2/token"),
                             delay: 1,
                             mockJSONFile("oauth_token"))

        let profileStub = stub(http(.get, uri: "/api/\(apiVersion)/users/app/profile"),
                               delay: 1,
                               mockJSONFile("\(apiVersion)_userprofile"))
        waitUntil(timeout: .seconds(10)) { [unowned self] done in
            self.prontoAuthentication.login(email: "bas@e-sites.nl", password: "1234").subscribe { event in
                switch event {
                case .success:
                    print("... waiting ...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.prontoAuthentication.getProfile().subscribe().disposed(by: self.disposeBag)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.prontoAuthentication.getProfile().subscribe { event in
                                switch event {
                                case .success:
                                    break
                                case .error(let error):
                                    XCTAssert(false, "\(error)")
                                }
                                self.removeStub(profileStub)
                                done()
                            }.disposed(by: self.disposeBag)
                        }
                    }
                case .error(let error):
                    XCTAssert(false, "\(error)")
                    self.removeStub(loginStub)
                    self.removeStub(profileStub)
                    done()
                }
            }.disposed(by: self.disposeBag)
        }
    }
}
