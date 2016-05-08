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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	class MockViewControllerOutput : ChatUsersStoryViewOutput {
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
