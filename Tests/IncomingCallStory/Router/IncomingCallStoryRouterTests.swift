//
//  IncomingCallStoryRouterTests.swift
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

class IncomingCallStoryRouterTests: BaseTestCase {

	var router: IncomingCallStoryRouter!
	var mockOutput: MockOutput!
	override func setUp() {
		super.setUp()
		router = IncomingCallStoryRouter()
		mockOutput = MockOutput()
		router.transitionHandler = mockOutput
	}
	
	func testRouterOpensVideoCallStoryCallsTransitionHandler() {
		// when
		router.openVideoStoryWithOpponent(TestsStorage.svuserRealUser1)
		
		// then
		XCTAssertEqual(mockOutput.openedModuleSegueIdentifier, router.incomingCallStoryToVideoStorySegue)
	}
	
	func testRouterUnwindsToChatStoryCallsTransitionHandler() {
		// when
		router.unwindToChatsUserStory()
		
		// then
		XCTAssertEqual(mockOutput.openedModuleSegueIdentifier, router.incomingCallStoryToChatsUserStoryModuleSegue)
	}
	
	func testSegues() {
		// given
		let identifiers = segues(ofViewController: UIStoryboard(name: "IncomingCallStory", bundle: nil).instantiateInitialViewController()!)
		
		// then
		XCTAssertTrue(identifiers.contains(router.incomingCallStoryToVideoStorySegue))
		XCTAssertTrue(identifiers.contains(router.incomingCallStoryToChatsUserStoryModuleSegue))
	}
	
	class MockOutput: IncomingCallStoryViewController {
		var openedModuleSegueIdentifier: String?
		override func openModuleUsingSegue(segueIdentifier: String!) -> RamblerViperOpenModulePromise! {
			openedModuleSegueIdentifier = segueIdentifier
			return RamblerViperOpenModulePromise()
		}
	}
}
