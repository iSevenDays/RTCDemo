//
//  VideoCallStoryViewTests.swift
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

class VideoCallStoryViewTests: XCTestCase {

	var controller: VideoCallStoryViewController!
	var mockOutput: MockViewControllerOutput!
	let emptySender = UIButton()
	
    override func setUp() {
        super.setUp()
        controller = UIStoryboard(name: "VideoCallStory", bundle: nil).instantiateViewControllerWithIdentifier(String(VideoCallStoryViewController.self)) as! VideoCallStoryViewController
		mockOutput = MockViewControllerOutput()
		controller.output = mockOutput
    }

    override func tearDown() {
        controller = nil
		mockOutput = nil
        super.tearDown()
    }
	
	// MARK: - Testing life cycle
	
	func testViewNotifiesPresenterOnDidLoad() {
		// when
		controller.viewDidLoad()
		
		// then
		XCTAssertTrue(mockOutput.viewIsReadyGotCalled)
	}
	
	// MARK: Testing IBActions
	
	func testHangupButtonTriggersAction() {
		// when
		controller.didTapButtonHangup(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.hangupButtonTapped)
	}
	
	func testSuccessDataChannelButton_ImageGalleryTriggersAction() {
		// when
		controller.didTapButtonDataChannelImageGallery(emptySender)
		
		// then
		XCTAssertTrue(mockOutput.dataChannelButtonTapped)
	}
	
	func testShowHangupEventuallyCallsCloseAction() {
		// when
		controller.showHangup()
		
		// then
		XCTAssertTrue(mockOutput.closeButtonTapped)
	}
	
	// MARK: Testing methods of VideoCallStoryViewInput
	
	func testSetLocalVideoCaptureSession_setsCaptureSession() {
		// given
		controller.loadView()
		let testCaptureSession = AVCaptureSession()
		
		// when
		controller.setLocalVideoCaptureSession(testCaptureSession)
		
		// then
		XCTAssertEqual(controller.viewLocal.captureSession, testCaptureSession)
	}

	class MockViewControllerOutput : VideoCallStoryViewOutput {
		var viewIsReadyGotCalled = false
		var hangupButtonTapped = false
		var dataChannelButtonTapped = false
		var closeButtonTapped = false
		
		func viewIsReady() {
			viewIsReadyGotCalled = true
		}
		
		func didTriggerHangupButtonTapped() {
			hangupButtonTapped = true
		}
		
		func didTriggerDataChannelButtonTapped() {
			dataChannelButtonTapped = true
		}
		
		func didTriggerCloseButtonTapped() {
			closeButtonTapped = true
		}
	}
}
