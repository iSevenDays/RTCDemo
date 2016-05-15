//
//  IncomingCallStoryPresenterTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
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


class IncomingCallStoryPresenterTest: XCTestCase {

	var presenter: IncomingCallStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
	override func setUp() {
		super.setUp()
		
		presenter = IncomingCallStoryPresenter()
		
		mockInteractor = MockInteractor()
		
		mockRouter = MockRouter()
		mockView = MockViewController()
		
		presenter.interactor = self.mockInteractor
		presenter.router = self.mockRouter
		presenter.view = self.mockView
	}
	
	func testPresenterConfiguresModule() {
		// given
		let opponent = TestsStorage.svuserRealUser1()
		
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		
		// then
		XCTAssertEqual(mockInteractor.retrieveOpponent(), opponent)
	}
	
	func testPresenterOpensVideoStory_whenCallHasBeenAccepted() {
		// given
		let opponent = TestsStorage.svuserRealUser1()
		
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		presenter.didTriggerAcceptButtonTapped()
		
		// then
		XCTAssertTrue(mockRouter.openVideoStoryWithOpponentGotCalled)
	}

    class MockInteractor: IncomingCallStoryInteractorInput {
		
		
		var opponent: SVUser?
		
		func setOpponent(opponent: SVUser) {
			self.opponent = opponent
		}
		
		func retrieveOpponent() -> SVUser {
			return opponent ?? SVUser()
		}
    }

	class MockRouter: IncomingCallStoryRouterInput {
		
		var openVideoStoryWithOpponentGotCalled = false
		
		func openVideoStoryWithOpponent(opponent: SVUser) {
			openVideoStoryWithOpponentGotCalled = true
		}
    }

    class MockViewController: IncomingCallStoryViewInput {

        func setupInitialState() {

        }
    }
}
