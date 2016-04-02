//
//  AuthStoryPresenterTests.swift
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

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testRetrieveUserNameAndRoomName() {
		// when
		
	}
	
    class MockInteractor: AuthStoryInteractorInput {

    }

    class MockRouter: AuthStoryRouterInput {

    }

    class MockViewController: AuthStoryViewInput {

        func setupInitialState() {

        }
		
		func enableInput() {
			
		}
		
		func disableInput() {
			
		}
		
		func setUserName(userName: String) {
			
		}
		
		func setRoomName(roomName: String) {
			
		}
		
		func retrieveInformation() {
			
		}
    }
}
