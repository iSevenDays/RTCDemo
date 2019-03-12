//
//  IncomingCallStoryInteractorTests.swift
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

class IncomingCallStoryInteractorTests: XCTestCase {

	var interactor: IncomingCallStoryInteractor!
	var mockOutput: MockOutput!
	var mockPresenter: MockPresent!
	
	override func setUp() {
		super.setUp()
		interactor = IncomingCallStoryInteractor()
		mockOutput = MockOutput()
		mockPresenter = MockPresent()
		mockOutput.signalingChannel = FakeSignalingChannel()
		ServicesConfigurator().configureCallService(mockOutput)
		interactor.callService = mockOutput
		interactor.output = mockPresenter
	}
	
	func testHangupSendsHangupMessage() {
		// given
		let testUser = TestsStorage.svuserRealUser1
		interactor.setOpponent(testUser)
		
		// when
		interactor.rejectCall()
		
		// then
		XCTAssertEqual(testUser, mockOutput.opponent)
	}
	
	// The opponent decided to cancel the offer
	func testCorrectlyProcessesHangupForIncomingCall() {
		// given
		let testUser = TestsStorage.svuserRealUser1
		interactor.setOpponent(testUser)
		
		// when
		interactor.callService(interactor.callService, didReceiveHangupFromOpponent: testUser)
		
		// then
		XCTAssertTrue(mockPresenter.didReceiveHangupForIncomingCallGotCalled)
	}
	
	// The undefined opponent decided to cancel an offer, not current call opponent
	func testDoesntCancelIncomingCallWhenHangupForIncomingCallIsReceivedFromUndefinedOpponent() {
		// given
		let testUser = TestsStorage.svuserRealUser1
		interactor.setOpponent(testUser)
		
		// when
		interactor.callService(interactor.callService, didReceiveHangupFromOpponent: TestsStorage.svuserRealUser2)
		
		// then
		XCTAssertFalse(mockPresenter.didReceiveHangupForIncomingCallGotCalled)
	}
	
	class MockOutput: FakeCallService {
		var opponent: SVUser?
		
		override func sendRejectCallToOpponent(_ user: SVUser) throws {
			opponent = user
		}
	}
	
	class MockPresent: IncomingCallStoryInteractorOutput {
		var didReceiveHangupForIncomingCallGotCalled = false
		func didReceiveHangupForIncomingCall() {
			didReceiveHangupForIncomingCallGotCalled = true
		}
	}
}
