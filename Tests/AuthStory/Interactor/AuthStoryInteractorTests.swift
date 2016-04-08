//
//  AuthStoryInteractorTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class AuthStoryInteractorTests: XCTestCase {

	var interactor: AuthStoryInteractor!
	var mockOutput: MockPresenter!
	
	let fakeService = FakeQBRESTService()
	//let realService = QBRESTService()
	
	let userName = "test"
	let tags = ["tag"]
	
    override func setUp() {
        super.setUp()
		interactor = AuthStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput
		
		interactor.restService = fakeService
    }

	override func tearDown() {
		super.tearDown()
		fakeService.tearDown()
	}
	
	func testNotifiesPresenterAboutSuccessfulLogin() {
		// given
		fakeService.shouldLoginSuccessfully = true
		
		// when
		interactor.signUpOrLoginWithUserName(userName, tags: tags)
		
		// then
		XCTAssertTrue(mockOutput.didLoginUserGotCalled)
	}
	
	func testNotifiesPresenterAboutSuccessfulLoginAfterSignup() {
		// given
		fakeService.shouldLoginSuccessfully = false
		fakeService.shouldLoginAfterSignupSuccessfully = true
		fakeService.shouldSignUpSuccessfully = true
		
		// when
		interactor.signUpOrLoginWithUserName(userName, tags: tags)
		
		// then
		XCTAssertTrue(mockOutput.didLoginUserGotCalled)
	}
	
	func testNotifiesPresenterAboutFailedLogin() {
		// given
		fakeService.shouldLoginSuccessfully = false
		fakeService.shouldLoginAfterSignupSuccessfully = false
		fakeService.shouldSignUpSuccessfully = false
		
		// when
		interactor.signUpOrLoginWithUserName(userName, tags: tags)
		
		// then
		XCTAssertTrue(mockOutput.didErrorLoginGotCalled)
	}
	
	func testNotifiesPresenterAboutDoingLogin() {
		// given
		fakeService.shouldLoginSuccessfully = true
		
		// when
		interactor.signUpOrLoginWithUserName(userName, tags: tags)
		
		// then
		XCTAssertTrue(mockOutput.doingLoginWithUserGotCalled)
	}
	
	func testNotifiesPresenterAboutDoingLoginWithCachedUser() {
		// given
		fakeService.shouldLoginSuccessfully = true
		
		// when
		interactor.cacheUser(SVUser.init(ID: 33, login: "login", fullName: "fullname", password: "pas", tags: ["tag"]))
		interactor.tryRetrieveCachedUser()
		
		// then
		XCTAssertTrue(mockOutput.doingLoginWithCachedUserGotCalled)
	}
	
	func testNotifiesPresenterAboutDoingSignUp() {
		// given
		fakeService.shouldLoginSuccessfully = false
		
		// when
		interactor.signUpOrLoginWithUserName(userName, tags: tags)
		
		// then
		XCTAssertTrue(mockOutput.doingSignUpWithUserGotCalled)
	}
	
	func testCachesUserAfterLogin() {
		// given
		fakeService.shouldLoginSuccessfully = true
		
		// when
		interactor.signUpOrLoginWithUserName(userName, tags: tags)
		
		// then
		let cachedUser = interactor.cachedUser()
		XCTAssertNotNil(cachedUser)
		XCTAssertEqual(cachedUser?.fullName, userName)
		XCTAssertEqual(cachedUser?.tags?.first, tags.first)
	}
	
    class MockPresenter: AuthStoryInteractorOutput {
		var doingLoginWithUserGotCalled = false
		var doingLoginWithCachedUserGotCalled = false
		
		var doingSignUpWithUserGotCalled = false
		var didLoginUserGotCalled = false
		var didErrorLoginGotCalled = false
		
		func doingLoginWithUser(user: SVUser) {
			doingLoginWithUserGotCalled = true
		}
		
		func doingLoginWithCachedUser(user: SVUser) {
			doingLoginWithCachedUserGotCalled = true
		}
		
		func doingSignUpWithUser(user: SVUser) {
			doingSignUpWithUserGotCalled = true
		}
		
		func didLoginUser(user: SVUser) {
			didLoginUserGotCalled = true
		}
		
		func didErrorLogin(error: NSError?) {
			didErrorLoginGotCalled = true
		}
    }
}
