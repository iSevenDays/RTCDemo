//
//  IncomingCallStoryPresenterTests.swift
//  RTCDemo
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
		
		presenter.interactor = mockInteractor
		presenter.router = mockRouter
		presenter.view = mockView
	}
	
	func testPresenterHandlesViewReadyEvent() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockView.setupInitialStateGotCalled)
	}
	
	func testPresenterConfiguresModule() {
		// given
		let opponent = TestsStorage.svuserRealUser1()
		
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		
		// then
		XCTAssertEqual(mockInteractor.retrieveOpponent(), opponent)
		XCTAssertTrue(mockView.configureViewWithCallInitiatorGotCalled)
		XCTAssertEqual(mockView.callInitiator, opponent)
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
	
	func testPresenterCallsRouterUnwindToChatsStory_whenCallHasBeenDeclined() {
		// given
		let opponent = TestsStorage.svuserRealUser1()
		
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		presenter.didTriggerDeclineButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.hangupGotCalled)
		XCTAssertTrue(mockRouter.unwindToChatsUserStoryGotCalled)
	}

    class MockInteractor: IncomingCallStoryInteractorInput {
		
		var hangupGotCalled = false
		var opponent: SVUser?
		
		func setOpponent(opponent: SVUser) {
			self.opponent = opponent
		}
		
		func retrieveOpponent() -> SVUser {
			return opponent ?? SVUser()
		}
		
		func hangup() {
			hangupGotCalled = true
		}
    }

	class MockRouter: IncomingCallStoryRouterInput {
		
		var openVideoStoryWithOpponentGotCalled = false
		var unwindToChatsUserStoryGotCalled = false
		
		func openVideoStoryWithOpponent(opponent: SVUser) {
			openVideoStoryWithOpponentGotCalled = true
		}
		
		func unwindToChatsUserStory() {
			unwindToChatsUserStoryGotCalled = true
		}
    }

    class MockViewController: IncomingCallStoryViewInput {

		var setupInitialStateGotCalled = false
		
		var configureViewWithCallInitiatorGotCalled = false
		var callInitiator: SVUser?
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func configureViewWithCallInitiator(callInitiator: SVUser) {
			configureViewWithCallInitiatorGotCalled = true
			self.callInitiator = callInitiator
		}
    }
}
