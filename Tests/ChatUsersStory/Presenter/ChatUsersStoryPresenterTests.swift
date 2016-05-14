//
//  ChatUsersStoryPresenterTests.swift
//  QBRTCDemo
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
	
	// MARK: ChatUsersStoryInteractorOutput tests
	
	func testViewReloadsData_whenPresenterRetrievesUsers() {
		// given 
		let testUsers = [TestsStorage.svuserTest()]
		
		// when
		presenter.didRetrieveUsers(testUsers)
		
		// then
		XCTAssertTrue(mockView.reloadDataGotCalled)
		XCTAssertEqualOptional(mockView.users, testUsers)
	}
	
	// MARK: ChatUsersStoryModuleInput tests
	func testCallsSetsTagWithInitiatorUser_whenStoryHasBeenLoaded() {
		// given
		let tag = "test chatroom name"
		let testUser = TestsStorage.svuserTest()
		
		// when
		presenter.setTag(tag, currentUser: testUser)
		
		// then
		XCTAssertTrue(mockInteractor.setTagGotCalled)
		XCTAssertEqual(mockInteractor.user, testUser)
		XCTAssertTrue(mockView.configureViewWithCurrentUserGotCalled)
	}

    class MockInteractor: ChatUsersStoryInteractorInput {
		var retrieveUsersWithTagGotCalled = false
		
		var setTagGotCalled = false
		var user: SVUser?
		
		func retrieveUsersWithTag() {
			retrieveUsersWithTagGotCalled = true
		}
		
		func retrieveCurrentUser() -> SVUser {
			return user!
		}
		
		func setTag(tag: String, currentUser: SVUser) {
			setTagGotCalled = true
			self.user = currentUser
		}
    }

    class MockRouter: ChatUsersStoryRouterInput {
		func openVideoStoryWithInitiator(initiator: SVUser, thenCallOpponent opponent: SVUser) {
			
		}
    }

    class MockViewController: ChatUsersStoryViewInput {

		var configureViewWithCurrentUserGotCalled = false
		
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
    }
}
