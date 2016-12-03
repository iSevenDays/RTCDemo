//
//  ImageGalleryStoryInteractorTests.swift
//  RTCDemo
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

class ImageGalleryStoryInteractorTests: XCTestCase {

	var interactor: ImageGalleryStoryInteractor!
	var mockOutput: MockPresenter!
	var mockImagesOutput: MockImagesOutput!
	
	let user1: SVUser = CallServiceHelpers.user1()
	let user2: SVUser = CallServiceHelpers.user2()
	
	
	var fakeCallService: FakeCallService!
	var realCallService: CallService!
	
    override func setUp() {
        super.setUp()
		interactor = ImageGalleryStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput
		
		mockImagesOutput = MockImagesOutput()
		
		interactor.imagesOutput = mockImagesOutput
		
		let fakeSignalingChannel: SVSignalingChannelProtocol = FakeSignalingChannel()
		
		fakeCallService = FakeCallService(signalingChannel: fakeSignalingChannel, callServiceDelegate: nil, dataChannelDelegate: interactor)
		realCallService = CallService(signalingChannel: fakeSignalingChannel, callServiceDelegate: nil, dataChannelDelegate: interactor)
    }
	
	// Use when using real CallService is not possible
	func useFakeCallService() {
		interactor.callService = fakeCallService
	}
	
	func useRealCallService() {
		
		interactor.callService = realCallService
	}
	
	func testStartsAndNotificatesAboutSynchronizationImages() {
		// given
		useFakeCallService()
		
		// when
		interactor.startSynchronizationImages()

		// then
		XCTAssertTrue(mockOutput.didStartSynchronizationImagesGotCalled)
	}
	
	func testShowsRoleSenderWhenCallerIsInitiator() {
		// given
		useRealCallService()
		interactor.callService.connectWithUser(user1, completion: nil)
		interactor.callService.startCallWithOpponent(user2)
		
		// when
		interactor.requestCallerRole()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRoleSenderGotCalled)
	}
	
	func testShowsRoleReceiverWhenCallerIsReceiver() {
		// given
		useRealCallService()
		interactor.callService.connectWithUser(user1, completion: nil)
		
		// when
		interactor.requestCallerRole()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRoleReceiverGotCalled)
	}
	
	// MARK: ImageGalleryStoryInteractorImagesOutput tests
	
	func testNotifiesImagesOutputWhenReceivedNewImage() {
		// given
		useRealCallService()
		
		
		UIGraphicsBeginImageContext(CGSizeMake(1, 1));
		let newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		let imageData = UIImagePNGRepresentation(newImage!)!
		
		// when
		interactor.callService(interactor.callService, didReceiveData: imageData)
		
		// then
		XCTAssertTrue(mockImagesOutput.didReceiveImageGotCalled)
	}
	
	
    class MockPresenter: ImageGalleryStoryInteractorOutput {
		
		var didStartSynchronizationImagesGotCalled = false
		var didFinishSynchronizationImagesGotCalled = false
		
		var didReceiveRoleReceiverGotCalled = false
		var didReceiveRoleSenderGotCalled = false
		
		func didStartSynchronizationImages() {
			didStartSynchronizationImagesGotCalled = true
		}
		
		func didFinishSynchronizationImages() {
			didFinishSynchronizationImagesGotCalled = true
		}
		
		func didReceiveRoleReceiver() {
			didReceiveRoleReceiverGotCalled = true
		}
		
		func didReceiveRoleSender() {
			didReceiveRoleSenderGotCalled = true
		}
    }
	
	class MockImagesOutput : ImageGalleryStoryInteractorImagesOutput {
		var didReceiveImageGotCalled = false
		
		func didReceiveImage(image: UIImage) {
			didReceiveImageGotCalled = true
		}
	}
}
