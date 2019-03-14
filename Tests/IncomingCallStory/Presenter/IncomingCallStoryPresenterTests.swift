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
	
	var opponent: SVUser!
	
	override func setUp() {
		super.setUp()
		
		presenter = IncomingCallStoryPresenter()
		
		mockInteractor = MockInteractor()
		
		mockRouter = MockRouter()
		mockView = MockViewController()
		
		presenter.interactor = mockInteractor
		presenter.router = mockRouter
		presenter.view = mockView
		
		opponent = TestsStorage.svuserRealUser1
	}
	
	func testPresenterHandlesViewReadyEvent() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockView.setupInitialStateGotCalled)
	}
	
	func testPresenterConfiguresModule() {
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		
		// then
		XCTAssertEqual(mockInteractor.retrieveOpponent(), opponent)
		XCTAssertTrue(mockView.configureViewWithCallInitiatorGotCalled)
		XCTAssertEqual(mockView.callInitiator, opponent)
	}
	
	func testPresenterOpensVideoStory_whenCallHasBeenAccepted() {
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		presenter.didTriggerAcceptButtonTapped()
		
		// then
		XCTAssertTrue(mockRouter.openVideoStoryWithOpponentGotCalled)
		XCTAssertTrue(mockInteractor.stopHandlingEventsGotCalled)
		XCTAssertTrue(mockView.hideViewGotCalled)
	}
	
	func testPresenterCallsRouterUnwindToChatsStory_whenCallHasBeenDeclined() {
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		presenter.didTriggerDeclineButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.rejectCallGotCalled)
		XCTAssertTrue(mockRouter.unwindToChatsUserStoryGotCalled)
	}
	
	func testPresenterCallsRouterUnwindToChatsStory_whenReceivedCloseAction() {
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		presenter.didTriggerCloseAction()
		
		// then
		XCTAssertTrue(mockRouter.unwindToChatsUserStoryGotCalled)
		XCTAssertFalse(mockInteractor.rejectCallGotCalled)
	}
	
	func testPresenterCallsViewShowOpponentDecidedToDeclineCall_whenHangupmessageIsReceivedForIncomingCall() {
		// when
		presenter.configureModuleWithCallInitiator(opponent)
		presenter.didReceiveHangupForIncomingCall()
		
		// then
		XCTAssertTrue(mockView.showOpponentDecidedToDeclineCallGotCalled)
	}

    class MockInteractor: IncomingCallStoryInteractorInput {
		
		var rejectCallGotCalled = false
		var stopHandlingEventsGotCalled = false
		var opponent: SVUser?
		
		func setOpponent(_ opponent: SVUser) {
			self.opponent = opponent
		}
		
		func retrieveOpponent() -> SVUser {
			return opponent ?? SVUser(ID: nil, login: nil, fullName: "unknown opponent", password: nil, tags: nil)
		}
		
		func rejectCall() {
			rejectCallGotCalled = true
		}
		
		func stopHandlingEvents() {
			stopHandlingEventsGotCalled = true
		}
    }

	class MockRouter: IncomingCallStoryRouterInput {
		
		var openVideoStoryWithOpponentGotCalled = false
		var unwindToChatsUserStoryGotCalled = false
		
		func openVideoStoryWithOpponent(_ opponent: SVUser) {
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
		
		var showOpponentDecidedToDeclineCallGotCalled = false
		var hideViewGotCalled = false
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func configureViewWithCallInitiator(_ callInitiator: SVUser) {
			configureViewWithCallInitiatorGotCalled = true
			self.callInitiator = callInitiator
		}
		
		func showOpponentDecidedToDeclineCall() {
			showOpponentDecidedToDeclineCallGotCalled = true
		}
		
		func hideView() {
			hideViewGotCalled = true
		}
    }
}
