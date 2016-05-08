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
		controller = UIStoryboard(name: "ImageGalleryStory", bundle: nil).instantiateViewControllerWithIdentifier(String( ImageGalleryStoryViewController.self)) as! ImageGalleryStoryViewController
		
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
	}
	
	func testViewDidLoadTriggersViewIsReadyAction() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: IBActions
	
	func testStartButtonTriggersAction() {
		// when
		controller.didTapStartButton(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.startButtonTapped)
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

