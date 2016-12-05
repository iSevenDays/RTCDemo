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
	
	override func setUp() {
		super.setUp()
		interactor = IncomingCallStoryInteractor()
		mockOutput = MockOutput(signalingChannel: FakeSignalingChannel())
		interactor.callService = mockOutput
	}
	
	func testHangupSendsHangupMessage() {
		// given
		let testUser = TestsStorage.svuserRealUser1()
		interactor.opponent = testUser
		
		// when
		interactor.hangup()
		
		// then
		XCTAssertEqual(testUser, mockOutput.opponent)
	}
	
	class MockOutput: FakeCallService {
		var opponent: SVUser?
		override func sendHangupToUser(user: SVUser, completion: ((NSError?) -> Void)?) {
			opponent = user
		}
	}
}
