//
//  VideoCallStoryRouterTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
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

class VideoCallStoryRouterTests: BaseTestCase {

	var router: VideoCallStoryRouter!
	var mockTransitionHandler: MockTransitionHandler!
    override func setUp() {
        super.setUp()
		router = VideoCallStoryRouter()
		mockTransitionHandler = MockTransitionHandler()
		router.transitionHandler = mockTransitionHandler
    }
	
	func testRouterOpensImageGalleryCallsTransitionHandler() {
		// when
		router.openImageGallery()
		
		// then
		XCTAssertEqual(mockTransitionHandler.openedModuleSegueIdentifier, router.videoStoryToImageGalleryModuleSegue)
	}
	
	func testRouterUnwindsToChatStoryCallsTransitionHandler() {
		// when
		router.unwindToChatsUserStory()
		
		// then
		XCTAssertEqual(mockTransitionHandler.openedModuleSegueIdentifier, router.videoStoryToChatsUserStoryModuleSegue)
	}
	
	func testSegues() {
		// given
		let identifiers = segues(ofViewController: UIStoryboard(name: "VideoCallStory", bundle: nil).instantiateViewControllerWithIdentifier("VideoCallStoryViewController"))
		
		// then
		XCTAssertTrue(identifiers.contains(router.videoStoryToImageGalleryModuleSegue))
		XCTAssertTrue(identifiers.contains(router.videoStoryToChatsUserStoryModuleSegue))
	}
	
	class MockTransitionHandler: NSObject, RamblerViperModuleTransitionHandlerProtocol {
		var openedModuleSegueIdentifier: String?
		func openModuleUsingSegue(segueIdentifier: String!) -> RamblerViperOpenModulePromise! {
			openedModuleSegueIdentifier = segueIdentifier
			return RamblerViperOpenModulePromise()
		}
	}
}
