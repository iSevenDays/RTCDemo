//
//  AuthStoryPresenterTests.swift
//  RTCDemo
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

class AuthStoryPresenterTests: XCTestCase {

	var presenter: AuthStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
    override func setUp() {
        super.setUp()
		
		self.presenter = AuthStoryPresenter()
		
		self.mockInteractor = MockInteractor()
		
		self.mockRouter = MockRouter()
		self.mockView = MockViewController()
		
		self.presenter.interactor = self.mockInteractor
		self.presenter.router = self.mockRouter
		self.presenter.view = self.mockView
    }
	
	// MARK: AuthStoryViewOutput tests
	
	func testTriesToLoginWithCachedIfAvailable_whenViewIsReady() {
		// given
		presenter.interactor.signUpOrLoginWithUserName("test", tags: ["tag"])
		
		// when
		presenter.viewIsReady();
		
		// then
		XCTAssertTrue(mockInteractor.tryLoginWithCachedUserGotCalled)
		XCTAssertTrue(mockInteractor.signUpOrLoginWithUserNameGotCalled)
	}
	
	func testHandlesLoginWithUserNameAndRoomName() {
		// when
		presenter.didTriggerLoginButtonTapped("userName", roomName: "roomName")
		
		// then
		XCTAssertTrue(mockView.disableInputGotCalled)
		XCTAssertTrue(mockInteractor.signUpOrLoginWithUserNameGotCalled)
	}
	
	// MARK: AuthStoryInteratorOutput tests
	
	func testShowsLoggingInIndicator() {
		// when
		self.presenter.doingLoginWithUser(TestsStorage.svuserTest)
		
		// then
		XCTAssertTrue(self.mockView.showIndicatorLoggingInGotCalled)
		XCTAssertTrue(self.mockView.setUserNameGotCalled)
		XCTAssertTrue(self.mockView.setRoomNameGotCalled)
	}
	
	func testShowsSigningUpIndicator() {
		// when
		self.presenter.doingSignUpWithUser(TestsStorage.svuserTest)
		
		// then
		XCTAssertTrue(self.mockView.showIndicatorSigningUpGotCalled)
		XCTAssertTrue(self.mockView.setUserNameGotCalled)
		XCTAssertTrue(self.mockView.setRoomNameGotCalled)
	}
	
	func testOpensVideoStory_whenLoggedIn() {
		// given
		let testUser = TestsStorage.svuserTest
		
		// when
		self.presenter.didLoginUser(testUser)
		
		// then
		XCTAssertTrue(self.mockRouter.openChatUsersStoryGotCalled)
		XCTAssertNotNil(self.mockRouter.tag)
		XCTAssertEqual(self.mockRouter.tag, testUser.tags?.first)
	}
	
	func testShowsError_whenLoginFailed() {
		// when
		self.presenter.didErrorLogin(nil)
		
		// then
		XCTAssertTrue(self.mockView.showErrorLoginGotCalled)
	}
	
    class MockInteractor: AuthStoryInteractorInput {
		var tryLoginWithCachedUserGotCalled = false
		var signUpOrLoginWithUserNameGotCalled = false
		
		func tryLoginWithCachedUser() {
			tryLoginWithCachedUserGotCalled = true
		}
		
		func signUpOrLoginWithUserName(userName: String, tags: [String]) {
			signUpOrLoginWithUserNameGotCalled = true
		}
		
    }

    class MockRouter: AuthStoryRouterInput {
		var openChatUsersStoryGotCalled = false
		var tag: String?
		var user: SVUser?
		
		func openChatUsersStoryWithTag(tag: String, currentUser: SVUser) {
			openChatUsersStoryGotCalled = true
			self.tag = tag
			self.user = currentUser
		}
    }

    class MockViewController: AuthStoryViewInput {
		var enableInputGotCalled = false
		var disableInputGotCalled = false
		
		var setUserNameGotCalled = false
		var setRoomNameGotCalled = false
		
		var retrieveInformationGotCalled = false
		
		var showIndicatorLoggingInGotCalled = false
		var showIndicatorSigningUpGotCalled = false
		
		var showErrorLoginGotCalled = false
		
        func setupInitialState() {

        }
		
		func enableInput() {
			enableInputGotCalled = true
		}
		
		func disableInput() {
			disableInputGotCalled = true
		}
		
		func setUserName(userName: String) {
			setUserNameGotCalled = true
		}
		
		func setRoomName(roomName: String) {
			setRoomNameGotCalled = true
		}
		
		func retrieveInformation() {
			retrieveInformationGotCalled = true
		}
		
		func showIndicatorLoggingIn() {
			showIndicatorLoggingInGotCalled = true
		}
		
		func showIndicatorSigningUp() {
			showIndicatorSigningUpGotCalled = true
		}
		
		func showErrorLogin() {
			showErrorLoginGotCalled = true
		}
    }
}
