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

class VideoCallStoryRouterTests: XCTestCase {

	var router: VideoCallStoryRouter!
	var mockTransitionHandler: MockTransitionHandler!
    override func setUp() {
        super.setUp()
		router = VideoCallStoryRouter()
		mockTransitionHandler = MockTransitionHandler()
		router.transitionHandler = mockTransitionHandler
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testRouterOpensImageGalleryCallsTransitionHandler() {
		// when
		router.openImageGallery()
		
		// then
		XCTAssertEqual(mockTransitionHandler.openedModuleSegueIdentifier, router.videoStoryToImageGalleryModuleSegue)
	}
	
	class MockTransitionHandler: NSObject, RamblerViperModuleTransitionHandlerProtocol {
		var openedModuleSegueIdentifier: String?
		func openModuleUsingSegue(segueIdentifier: String!) -> RamblerViperOpenModulePromise! {
			openedModuleSegueIdentifier = segueIdentifier
			return RamblerViperOpenModulePromise()
		}
	}
}
