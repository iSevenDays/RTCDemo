//
//  AuthStoryRouterTests.swift
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

class AuthStoryRouterTests: BaseTestCase {

	var router: AuthStoryRouter!
	var mockOutput: MockOutput!
	override func setUp() {
		super.setUp()
		router = AuthStoryRouter()
		mockOutput = MockOutput()
		router.transitionHandler = mockOutput
	}
	
	func testRouterOpensChatUsersCallsTransitionHandler() {
		// when
		router.openChatUsersStoryWithTag("tag", currentUser: TestsStorage.svuserRealUser1)
		
		// then
		XCTAssertEqual(mockOutput.openedModuleSegueIdentifier, router.authStoryToChatUsersStorySegueIdentifier)
	}
	
	func testSegues() {
		// given
		let identifiers = segues(ofViewController: UIStoryboard(name: "AuthStory", bundle: nil).instantiateViewController(withIdentifier: "AuthStoryViewController"))
		
		// then
		XCTAssertTrue(identifiers.contains(router.authStoryToChatUsersStorySegueIdentifier))
	}
	
	class MockOutput: AuthStoryViewController {
		var openedModuleSegueIdentifier: String?
		override func openModule(usingSegue segueIdentifier: String!) -> RamblerViperOpenModulePromise! {
			openedModuleSegueIdentifier = segueIdentifier
			return RamblerViperOpenModulePromise()
		}
	}
}
