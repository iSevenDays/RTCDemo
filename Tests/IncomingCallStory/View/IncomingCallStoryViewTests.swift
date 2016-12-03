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
	
	override func setUp() {
		super.setUp()
		controller = UIStoryboard(name: "IncomingCallStory", bundle: nil).instantiateViewControllerWithIdentifier(String(IncomingCallStoryViewController.self)) as! IncomingCallStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
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
		controller.acceptCall()
		
		// then
		XCTAssertTrue(mockOutput.didTriggerAcceptButtonTappedGotCalled)
	}
	
	// MARK: - Testing methods of IncomingCallStoryViewInput
	
	func testConfigureViewWithUser() {
		// given
		let callInitiator = TestsStorage.svuserRealUser1()
		
		// when
		controller.configureViewWithCallInitiator(callInitiator)
		
		// then
		XCTAssertEqual(controller.lblIncomingCall.text, "Incoming call from: " + callInitiator.fullName)
	}
	
	class MockViewControllerOutput : NSObject, IncomingCallStoryViewOutput {
		var viewIsReadyGotCalled = false
		var didTriggerAcceptButtonTappedGotCalled = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerAcceptButtonTapped() {
			didTriggerAcceptButtonTappedGotCalled = true
		}
		
		
	}
}
