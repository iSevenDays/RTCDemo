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
		XCTAssertTrue(mockInteractor.tryRetrieveCachedUsersWithTagGotCalled)
	}
	

    class MockInteractor: ChatUsersStoryInteractorInput {
		var tryRetrieveCachedUsersWithTagGotCalled = false
		
		func tryRetrieveCachedUsersWithTag() {
			tryRetrieveCachedUsersWithTagGotCalled = true
		}
    }

    class MockRouter: ChatUsersStoryRouterInput {

    }

    class MockViewController: ChatUsersStoryViewInput {

        func setupInitialState() {

        }
		
		func reloadData() {
			
		}
    }
}
