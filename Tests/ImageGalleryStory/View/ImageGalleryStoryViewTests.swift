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
	
	// MARK: IBActions
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		self.controller.viewDidLoad()
		
		// then
		XCTAssertTrue(self.mockOutput.viewIsReadyGotCalled)
	}
	
	func testStartButtonTriggersAction() {
		// when
		self.controller.didTapStartButton(emptySender)
		
		// then
		XCTAssertTrue(self.mockOutput.startButtonTapped)
	}
	
	@objc class MockViewControllerOutput : NSObject,  ImageGalleryStoryViewOutput {
		var viewIsReadyGotCalled = false
		var startButtonTapped = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerStartButtonTapped() {
			startButtonTapped = true
		}
		
	}
}

