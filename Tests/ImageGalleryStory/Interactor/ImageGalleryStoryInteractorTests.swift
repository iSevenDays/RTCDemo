//
//  ImageGalleryStoryInteractorTests.swift
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

class ImageGalleryStoryInteractorTests: XCTestCase {

	var interactor: ImageGalleryStoryInteractor!
	var mockOutput: MockPresenter!
	
	let user1: SVUser = CallServiceHelpers.user1()
	let user2: SVUser = CallServiceHelpers.user2()
	
    override func setUp() {
        super.setUp()
		self.interactor = ImageGalleryStoryInteractor()
		self.mockOutput = MockPresenter()
		self.interactor.output = mockOutput
    }
	
	// Use when using real CallService is not possible
	func useFakeCallService() {
		let fakeSignalingChannel:SVSignalingChannelProtocol = FakeSignalingChannel()
		self.interactor.callService = FakeCallService(signalingChannel: fakeSignalingChannel, callServiceDelegate: nil, dataChannelDelegate: self.interactor)
	}
	
	func useRealCallService() {
		let fakeSignalingChannel:SVSignalingChannelProtocol = FakeSignalingChannel()
		self.interactor.callService = CallService(signalingChannel: fakeSignalingChannel, callServiceDelegate: nil, dataChannelDelegate: self.interactor)
	}
	
	func testNotificatesAboutStartingSynchronizationImages() {
		// given
		
		// when
		self.interactor.startSynchronizationImages()

		// then
		XCTAssertTrue(self.mockOutput.didStartSynchronizationImagesGotCalled)
	}
	
	func testShowsRoleSenderWhenCallerIsInitiator() {
		// given
		self.useRealCallService()
		self.interactor.callService.connectWithUser(self.user1, completion: nil)
		self.interactor.callService.startCallWithOpponent(self.user2)
		
		// when
		self.interactor.requestCallerRole()
		
		// then
		XCTAssertTrue(self.mockOutput.didReceiveRoleSenderGotCalled)
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
}
