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
		XCTAssertTrue(mockInteractor.tryRetrieveUsersWithTagGotCalled)
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
	

    class MockInteractor: ChatUsersStoryInteractorInput {
		var tryRetrieveUsersWithTagGotCalled = false
		
		func retrieveUsersWithTag() {
			tryRetrieveUsersWithTagGotCalled = true
		}
    }

    class MockRouter: ChatUsersStoryRouterInput {

    }

    class MockViewController: ChatUsersStoryViewInput {

		var reloadDataGotCalled = false
		var users: [SVUser]?
		
        func setupInitialState() {

        }
		
		func reloadDataWithUsers(users: [SVUser]) {
			reloadDataGotCalled = true
			self.users = users
		}
    }
}
