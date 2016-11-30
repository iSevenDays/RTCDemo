//
//  VideoStoryInteractorTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 30.11.16.
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


// Note: when possible, useRealCallService is used
class VideoStoryInteractorTests: XCTestCase {

	var interactor: VideoStoryInteractor!
	var mockOutput: MockPresenter!
	var testUser: SVUser!
	var testUser2: SVUser!
	
	override func setUp() {
		super.setUp()
		testUser = TestsStorage.svuserRealUser1()
		testUser2 = TestsStorage.svuserRealUser2()
		interactor = VideoStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput
	}
	
	override func tearDown() {
		interactor.output = nil
		interactor = nil
		mockOutput = nil
		super.tearDown()
	}
	
	func useFakeCallService() {
		interactor.callService = FakeCallService(signalingChannel: FakeSignalingChannel(), callServiceDelegate: interactor, dataChannelDelegate: interactor)
	}
	
	func useRealCallService() {
		interactor.callService = CallService(signalingChannel: FakeSignalingChannel(), callServiceDelegate: interactor, dataChannelDelegate: interactor)
	}
	
	// MARK: - Testing methods VideoStoryInteractorInput
	
	func testConnectsWithTestUser() {
		// given
		useRealCallService()
		let testUser = TestsStorage.svuserTest()
		
		// when
		interactor.connectToChatWithUser(testUser, callOpponent: nil)
		
		// then
		XCTAssertEqual(testUser, mockOutput.connectedToChatUser)
		XCTAssertTrue(mockOutput.didConnectToChatWithUserGotCalled)
	}
	
	func testHangup() {
		// given
		useRealCallService()
		
		let callService = interactor.callService
		callService.state = CallServiceState.ClientStateConnected
		
		// when
		interactor.hangup()
		
		// then
		XCTAssertTrue(mockOutput.didHangupGotCalled)
	}
	
	func testSuccessfullySetsLocalCaptureSession() {
		// given
		useRealCallService()
		
		// when
		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didSetLocalCaptureSessionGotCalled)
	}
	
	func testReceivesRemoteVideoTrack_whenConnectedAndStartedCall() {
		// given
		useFakeCallService()
		
		// when
		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled)
	}
	
	// MARK:- Data Channel Tests
	func testTriggersDidOpenDataChannelOpen_whenReceivedDataChannel() {
		// given
		useFakeCallService()
		
		// when
		interactor.callService.dataChannelEnabled = true
		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didOpenDataChannelGotCalled)
	}
	
	func testTriggersDidReceiveDataChannelStateReady_whenReceivedDataChannel() {
		// given
		useFakeCallService()
		
		// when
		interactor.callService.dataChannelEnabled = true
		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
		interactor.requestDataChannelState()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveDataChannelStateReadyGotCalled)
	}
	
	func testTriggersDidReceiveDataChannelStateNotReady_whenNoDataChannel() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.dataChannelEnabled = true
		interactor.requestDataChannelState()
		
		// then
		
		XCTAssertTrue(mockOutput.didReceiveDataChannelStateNotReadyGotCalled)
	}
	
	func testTriggersDidReceiveInvitationToOpenImageGallery_whenReceivedDataChannelInvitationMessage() {
		// given
		useFakeCallService()
		
		// when
		interactor.callService.dataChannelEnabled = true
		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
		
		let invitationData = DataChannelMessages.invitationToOpenImageGallery().dataUsingEncoding(NSUTF8StringEncoding)
		let invitationMessage = RTCDataBuffer(data: invitationData, isBinary: false)
		
		interactor.callService.channel(nil, didReceiveMessageWithBuffer: invitationMessage)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveInvitationToOpenImageGalleryGotCalled)
	}
	
	func testTriggersSendInvitationToOpenImageGallery_whenRequestedImageGallery() {
		// given
		useFakeCallService()
		
		// when
		interactor.callService.dataChannelEnabled = true
		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
		
		guard let fakeCallService = interactor.callService as? FakeCallService else {
			XCTFail("We have to use fakeCallService here")
			return
		}
		
		fakeCallService.setHasActiveCall(true)
		
		interactor.sendInvitationMessageAndOpenImageGallery()
		
		// then
		XCTAssertTrue(mockOutput.didSendInvitationToOpenImageGalleryGotCalled)
	}
	
	
	class MockPresenter: NSObject,  VideoStoryInteractorOutput {
		var didConnectToChatWithUserGotCalled = false
		var connectedToChatUser: SVUser?
		
		var didHangupGotCalled = false
		var didFailToConnectToChatGotCalled = false
		var didSetLocalCaptureSessionGotCalled = false
		var didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled = false
		var didOpenDataChannelGotCalled = false
		var didReceiveDataChannelStateReadyGotCalled = false
		var didReceiveDataChannelStateNotReadyGotCalled = false
		var didReceiveInvitationToOpenImageGalleryGotCalled = false
		var didSendInvitationToOpenImageGalleryGotCalled = false
		
		func didConnectToChatWithUser(user: SVUser) {
			connectedToChatUser = user
			didConnectToChatWithUserGotCalled = true
		}
		
		func didHangup() {
			didHangupGotCalled = true
		}
		
		func didFailToConnectToChat() {
			
		}
		
		func didSetLocalCaptureSession(localCaptureSession: AVCaptureSession) {
			didSetLocalCaptureSessionGotCalled = true
		}
		
		func didReceiveRemoteVideoTrackWithConfigurationBlock(block: ((renderer: RTCEAGLVideoView?) -> Void)?) {
			didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled = true
		}
		func didOpenDataChannel() {
			didOpenDataChannelGotCalled = true
		}
		
		func didReceiveDataChannelStateReady() {
			didReceiveDataChannelStateReadyGotCalled = true
		}
		
		func didReceiveDataChannelStateNotReady() {
			didReceiveDataChannelStateNotReadyGotCalled = true
		}
		
		func didReceiveInvitationToOpenImageGallery() {
			didReceiveInvitationToOpenImageGalleryGotCalled = true
		}
		
		func didSendInvitationToOpenImageGallery() {
			didSendInvitationToOpenImageGalleryGotCalled = true
		}
	}
	
}
