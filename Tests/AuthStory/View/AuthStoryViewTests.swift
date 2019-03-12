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
	
	let emptySender = UIButton()
	
    override func setUp() {
        super.setUp()
		let identifier = String(describing: AuthStoryViewController.self)
		let vc = UIStoryboard(name: "AuthStory", bundle: nil).instantiateViewController(withIdentifier: identifier)
		controller = vc as! AuthStoryViewController
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
		controller.alertControl = FakeAlertControl()
    }

	// MARK: AuthStoryViewOutput
	func testViewDidLoadTriggersViewIsReadyAction() {
		// given
		controller.loadView()
		
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: IBActions
	
	func testLoginButtonTriggersAction() {
		// given
		controller.loadView()
		controller.setUserName("test")
		controller.setRoomName("test")
		// when
		controller.didTapLoginButton(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.loginButtonTapped)
	}
	
	func testReturnsUserNameAndRoomName() {
		// given
		let userName = "user"
		let roomName = "room"
		
		controller.loadView()
		
		controller.setUserName(userName)
		controller.setRoomName(roomName)
		
		// when
		controller.retrieveInformation()
		
		// then
		XCTAssertEqual(mockOutput.userName, userName)
		XCTAssertEqual(mockOutput.roomName, roomName)
		XCTAssertTrue(mockOutput.didReceiveUserNameGotCalled)
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
		
		func didTriggerLoginButtonTapped(_ userName: String, roomName: String) {
			loginButtonTapped = true
		}
		
		func didReceiveUserName(_ userName: String, roomName: String) {
			didReceiveUserNameGotCalled = true
			self.userName = userName
			self.roomName = roomName
		}
	}


}
