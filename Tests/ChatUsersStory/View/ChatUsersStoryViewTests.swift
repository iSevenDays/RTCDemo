//
//  ChatUsersStoryViewTests.swift
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

class ChatUsersStoryViewTests: XCTestCase {

	var controller: ChatUsersStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	
    override func setUp() {
        super.setUp()
		controller = UIStoryboard(name: "ChatUsersStory", bundle: nil).instantiateViewControllerWithIdentifier(String(ChatUsersStoryViewController.self)) as! ChatUsersStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
    }
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: IBActions
	
	@objc class MockViewControllerOutput : NSObject,  ChatUsersStoryViewOutput {
		var viewIsReadyGotCalled = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		
	}

}
