//
//  IncomingCallStoryViewTests.swift
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

class IncomingCallStoryViewTests: XCTestCase {

	var controller: IncomingCallStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	
	override func setUp() {
		super.setUp()
		self.controller = UIStoryboard(name: "IncomingCallStory", bundle: nil).instantiateViewControllerWithIdentifier(String(IncomingCallStoryViewController.self)) as! IncomingCallStoryViewController
		
		self.mockOutput = MockViewControllerOutput()
		self.controller.output = self.mockOutput
	}

	// MARK: AuthStoryViewOutput
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		self.controller.viewDidLoad()
		
		// then
		XCTAssertTrue(self.mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: IBActions
	
	func testAcceptButtonTriggersAction() {
		// given
		self.controller.loadView()
		
		// when
		self.controller.acceptCall()
		
		// then
		XCTAssertTrue(self.mockOutput.didTriggerAcceptButtonTappedGotCalled)
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
