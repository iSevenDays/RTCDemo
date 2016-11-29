//
//  ChatUsersStoryRouterTests.swift
//  RTCDemo
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

class ChatUsersStoryRouterTests: XCTestCase {

	var router: ChatUsersStoryRouter!
	var mockOutput: MockOutput!
	
    override func setUp() {
        super.setUp()
		
		router = ChatUsersStoryRouter()
		mockOutput = MockOutput()
		
		router.transitionHandler = mockOutput
    }

	func testRouterOpensVideoStory() {
		// given
		let initiator = TestsStorage.svuserRealUser1()
		let opponent = TestsStorage.svuserRealUser2()
		
		// when
		router.openVideoStoryWithInitiator(initiator, thenCallOpponent: opponent)
		
		// then
		XCTAssertTrue(mockOutput.openModuleUsingSegueGotCalled)
		XCTAssertEqual(mockOutput.segueIdentifier, router.chatUsersStoryToVideoStorySegueIdentifier)
	}
	
	class MockOutput: NSObject, RamblerViperModuleTransitionHandlerProtocol {
		var openModuleUsingSegueGotCalled = false
		var segueIdentifier: String?
		
		func openModuleUsingSegue(segueIdentifier: String!) -> RamblerViperOpenModulePromise! {
			openModuleUsingSegueGotCalled = true
			self.segueIdentifier = segueIdentifier
			
			return RamblerViperOpenModulePromise()
		}
	}
}
