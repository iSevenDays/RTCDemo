//
//  IncomingCallStoryViewTests.swift
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

class IncomingCallStoryViewTests: XCTestCase {

	var controller: IncomingCallStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	var callInitiator: SVUser!
	
	override func setUp() {
		super.setUp()
		controller = UIStoryboard(name: "IncomingCallStory", bundle: nil).instantiateViewController(withIdentifier: String(describing: IncomingCallStoryViewController.self)) as! IncomingCallStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
		
		callInitiator = TestsStorage.svuserRealUser1
	}

	// MARK: AuthStoryViewOutput
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: IBActions
	
	func testAcceptButtonTriggersAction() {
		// when
		controller.acceptCall(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.didTriggerAcceptButtonTappedGotCalled)
	}
	
	func testDeclineButtonTriggersAction() {
		// when
		controller.declineCall(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.didTriggerDeclineButtonTappedGotCalled)
	}
	
	// MARK: - Testing methods of IncomingCallStoryViewInput
	
	func testConfigureViewWithUser() {
		// when
		controller.configureViewWithCallInitiator(callInitiator)
		
		// then
		XCTAssertEqual(controller.lblIncomingCall.text, "Incoming call from " + callInitiator.fullName)
	}
	
	func testShowOpponentDeclinedCallEventuallyCallsCloseAction() {
		// when
		controller.configureViewWithCallInitiator(callInitiator)
		controller.showOpponentDecidedToDeclineCall()
		
		// then
		XCTAssertTrue(mockOutput.didTriggerCloseActionGotCalled)
	}
	
	class MockViewControllerOutput : NSObject, IncomingCallStoryViewOutput {
		var viewIsReadyGotCalled = false
		var didTriggerAcceptButtonTappedGotCalled = false
		var didTriggerDeclineButtonTappedGotCalled = false
		var didTriggerCloseActionGotCalled = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerAcceptButtonTapped() {
			didTriggerAcceptButtonTappedGotCalled = true
		}
		
		func didTriggerDeclineButtonTapped() {
			didTriggerDeclineButtonTappedGotCalled = true
		}
		
		func didTriggerCloseAction() {
			didTriggerCloseActionGotCalled = true
		}
	}
}
