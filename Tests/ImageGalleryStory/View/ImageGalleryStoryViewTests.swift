//
//  ImageGalleryStoryViewTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15/02/2016.
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

class ImageGalleryStoryViewTests: XCTestCase {

	var controller: ImageGalleryStoryViewController!
	var mockOutput: MockViewControllerOutput!
	
	let emptySender = UIResponder()
	
    override func setUp() {
        super.setUp()
		self.controller = UIStoryboard(name: "ImageGalleryStory", bundle: nil).instantiateViewControllerWithIdentifier(String( ImageGalleryStoryViewController.self)) as! ImageGalleryStoryViewController
		self.mockOutput = MockViewControllerOutput()
		self.controller.output = self.mockOutput
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	
	// MARK: IBActions
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// given
		
		// when
		self.controller.viewDidLoad()
		
		// then
		XCTAssertTrue(self.mockOutput.viewIsReadyGotCalled)
	}
	
	func testStartButtonTriggersAction() {
		// given
		
		// when
		self.controller.didTapStartButton(emptySender)
		
		// then
		XCTAssertTrue(self.mockOutput.startButtonTaped)
	}
	
	class MockViewControllerOutput : ImageGalleryStoryViewOutput {
		var viewIsReadyGotCalled = false
		var startButtonTaped = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerStartButtonTaped() {
			startButtonTaped = true
		}
		
	}
}

