//
//  AuthStoryViewTests.swift
//  RTCDemo
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

class AuthStoryViewTests: XCTestCase {

	var controller: AuthStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	
    override func setUp() {
        super.setUp()
		self.controller = UIStoryboard(name: "AuthStory", bundle: nil).instantiateViewControllerWithIdentifier(String(AuthStoryViewController.self)) as! AuthStoryViewController
		
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
	
	func testLoginButtonTriggersAction() {
		// given
		self.controller.loadView()
		
		// when
		self.controller.didTapLoginButton(emptySender)
		
		// then
		XCTAssertTrue(self.mockOutput.loginButtonTapped)
	}
	
	func testReturnsUserNameAndRoomName() {
		// given
		let userName = "user"
		let roomName = "room"
		
		self.controller.loadView()
		
		self.controller.setUserName(userName)
		self.controller.setRoomName(roomName)
		
		// when
		self.controller.retrieveInformation()
		
		// then
		XCTAssertEqual(self.mockOutput.userName, userName)
		XCTAssertEqual(self.mockOutput.roomName, roomName)
		XCTAssertTrue(self.mockOutput.didReceiveUserNameGotCalled)
	}
	
	class MockViewControllerOutput : AuthStoryViewOutput {
		var viewIsReadyGotCalled = false
		var loginButtonTapped = false
		var didReceiveUserNameGotCalled = false
		
		var roomName = ""
		var userName = ""
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerLoginButtonTapped(userName: String, roomName: String) {
			loginButtonTapped = true
		}
		
		func didReceiveUserName(userName: String, roomName: String) {
			didReceiveUserNameGotCalled = true
			self.userName = userName
			self.roomName = roomName
		}
	
	}


}
