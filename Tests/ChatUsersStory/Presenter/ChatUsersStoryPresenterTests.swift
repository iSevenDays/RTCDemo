//
//  ChatUsersStoryPresenterTests.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
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

class ChatUsersStoryPresenterTest: XCTestCase {

	var presenter: ChatUsersStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
    override func setUp() {
        super.setUp()
		presenter = ChatUsersStoryPresenter()
		
		mockInteractor = MockInteractor()
		
		mockRouter = MockRouter()
		mockView = MockViewController()
		
		presenter.interactor = mockInteractor
		presenter.router = mockRouter
		presenter.view = mockView
    }

	// MARK: ChatUsersStoryViewOutput tests
	
	func testTriesToRetrieveCachedUsersWithTag_whenViewIsReady() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockInteractor.retrieveUsersWithTagGotCalled)
	}
	
	func testPresenterRequestsPermissionsForCall_whenOpponentHasBeenSelected() {
		// given
		let tag = "test chatroom name"
		let testUser = TestsStorage.svuserTest
		let opponentUser = TestsStorage.svuserRealUser1
		
		// when
		presenter.setTag(tag, currentUser: testUser)
		presenter.didTriggerUserTapped(opponentUser)
		
		// then
		XCTAssertFalse(mockRouter.openVideoStoryWithInitiatorGotCalled)
		XCTAssertNil(mockRouter.opponent)
		XCTAssertTrue(mockInteractor.requestCallWithOpponentGotCalled)
	}
	
	func testPresenterOpensVideoStory_whenPermissonForCallHasBeenReceived() {
		// given
		let tag = "test chatroom name"
		let testUser = TestsStorage.svuserTest
		let opponentUser = TestsStorage.svuserRealUser1
		mockInteractor.user = testUser
		
		// when
		presenter.setTag(tag, currentUser: testUser)
		presenter.didReceiveApprovedRequestForCallWithOpponent(opponentUser)
		
		// then
		XCTAssertTrue(mockRouter.openVideoStoryWithInitiatorGotCalled)
		XCTAssertEqual(mockRouter.opponent, opponentUser)
	}
	
	func testPresenterHandlesDeclinedRequestForCall() {
		// given2
		let tag = "test chatroom name"
		let testUser = TestsStorage.svuserTest
		let opponentUser = TestsStorage.svuserRealUser1
		
		// when
		presenter.setTag(tag, currentUser: testUser)
		presenter.didDeclineRequestForCallWithOpponent(opponentUser, reason: "reason")
		
		// then
		XCTAssertFalse(mockRouter.openVideoStoryWithInitiatorGotCalled)
		XCTAssertNil(mockRouter.opponent)
		XCTAssertTrue(mockView.showErrorMessageGotCalled)
	}
	
	
	// MARK: ChatUsersStoryInteractorOutput tests
	
	func testViewReloadsData_whenPresenterRetrievesUsers() {
		// given 
		let testUsers = [TestsStorage.svuserTest]
		
		// when
		presenter.didRetrieveUsers(testUsers)
		
		// then
		XCTAssertTrue(mockView.reloadDataGotCalled)
		XCTAssertEqualOptional(mockView.users, testUsers)
	}
	
	func testPresenterOpensIncomingCallStory_whenCallRequestHasBeenReceived() {
		// given
		let tag = "test chatroom name"
		let currentUser = TestsStorage.svuserTest
		let opponentUser = TestsStorage.svuserRealUser1
		
		// when
		presenter.setTag(tag, currentUser: currentUser)
		presenter.didReceiveCallRequestFromOpponent(opponentUser)
		
		// then
		XCTAssertTrue(mockRouter.openIncomingCallStoryWithOpponentGotCalled)
		XCTAssertEqual(mockRouter.opponent, opponentUser)
	}
	
	// MARK: ChatUsersStoryModuleInput tests
	func testCallsSetsTagWithInitiatorUser_whenStoryHasBeenLoaded() {
		// given
		let tag = "test chatroom name"
		let testUser = TestsStorage.svuserTest
		
		// when
		presenter.setTag(tag, currentUser: testUser)
		
		// then
		XCTAssertTrue(mockInteractor.setTagGotCalled)
		XCTAssertTrue(mockView.configureViewWithCurrentUserGotCalled)
	}
	

    class MockInteractor: ChatUsersStoryInteractorInput {
		var retrieveUsersWithTagGotCalled = false
		var requestCallWithOpponentGotCalled = false
		
		var setTagGotCalled = false
		var user: SVUser?
		
		func retrieveUsersWithTag() {
			retrieveUsersWithTagGotCalled = true
		}
		
		func retrieveCurrentUser() -> SVUser {
			return user!
		}
		
		func setChatRoomName(chatRoomName: String) {
			setTagGotCalled = true
		}
		
		func requestCallWithOpponent(opponent: SVUser) {
			requestCallWithOpponentGotCalled = true
		}
    }

    class MockRouter: ChatUsersStoryRouterInput {
		var initiator: SVUser?
		var opponent: SVUser?
		
		var openVideoStoryWithInitiatorGotCalled = false
		var openIncomingCallStoryWithOpponentGotCalled = false
		
		func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser) {
			self.initiator = initiator
			self.opponent = opponent
			openVideoStoryWithInitiatorGotCalled = true
		}
		
		func openIncomingCallStoryWithOpponent(opponent: SVUser) {
			openIncomingCallStoryWithOpponentGotCalled = true
			self.opponent = opponent
		}
    }

    class MockViewController: ChatUsersStoryViewInput {

		var configureViewWithCurrentUserGotCalled = false
		var showErrorMessageGotCalled = false
		
		var reloadDataGotCalled = false
		var users: [SVUser]?
		
        func setupInitialState() {

        }
		
		func configureViewWithCurrentUser(user: SVUser) {
			configureViewWithCurrentUserGotCalled = true
		}
		
		func reloadDataWithUsers(users: [SVUser]) {
			reloadDataGotCalled = true
			self.users = users
		}
		
		func showErrorMessage(message: String) {
			showErrorMessageGotCalled = true
		}
    }
}
