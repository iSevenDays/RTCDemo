//
//  VideoCallStoryInteractorTests.swift
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


// Note: when possible, useRealCallService is used
class VideoCallStoryInteractorTests: BaseTestCase {
	
	var interactor: VideoCallStoryInteractor!
	var mockOutput: MockPresenter!
	var testUser: SVUser!
	var testUser2: SVUser!
	
	var permissionsService: FakePermissionsService!
	
	override func setUp() {
		super.setUp()
		testUser = TestsStorage.svuserRealUser1
		testUser2 = TestsStorage.svuserRealUser2
		interactor = VideoCallStoryInteractor()
		mockOutput = MockPresenter()
		interactor.output = mockOutput
		interactor.pushService = FakePushNotificationsService()
		permissionsService = FakePermissionsService()
		interactor.permissionsService = permissionsService
	}
	
	func useFakeCallService() {
		let callService = FakeCallSevice()
		ServicesConfigurator().configureCallService(callService)
		callService.signalingChannel = FakeSignalingChannel()
		interactor.callService = callService
	}
	
	func useRealCallService() {
		let callService = CallService()
		callService.signalingChannel = FakeSignalingChannel()
		ServicesConfigurator().configureCallService(callService)
		interactor.callService = callService
	}
	
	// MARK: - Testing methods VideoStoryInteractorInput
	
	func testHangup() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		interactor.hangup()
		
		// then
		XCTAssertTrue(mockOutput.didHangupGotCalled)
	}
	
	func testDidReceiveHangupFromOpponent() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		interactor.callService(interactor.callService, didReceiveHangupFromOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveHangupFromOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, testUser2)
	}
	
	func testDidReceiveRejectFromOpponent() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		interactor.callService(interactor.callService, didReceiveRejectFromOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRejectFromOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, testUser2)
	}
	
	func testSuccessfullySetsLocalCaptureSession() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didSetLocalCaptureSessionGotCalled)
	}
	
	func testSendsPushNotificationToOpponentAboutNewCall_whenDialingIsStarted() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		// time to apply local SDP and start dialing, dialing must call send push event
		waitForTimeInterval(1)
		
		// then
		XCTAssertTrue(mockOutput.didSetLocalCaptureSessionGotCalled)
		XCTAssertTrue(mockOutput.didSwitchLocalVideoTrackStateGotCalled)
		XCTAssertTrue(mockOutput.localVideoTrackState ?? false)
		XCTAssertTrue(mockOutput.didSendPushNotificationAboutNewCallToOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, testUser2)
	}
	
	func testNotifiesOutputAboutStartedCall_whenDialingIsStarted() {
		// given
		useRealCallService()
		
		// when
		interactor.callService(interactor.callService, didStartDialingOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didStartDialingOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, testUser2)
	}
	
	func testNotifiesOutputAboutAnswerForACall_whenAnswerIsReceived() {
		// given
		useRealCallService()
		
		// when
		interactor.callService(interactor.callService, didReceiveAnswerFromOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveAnswerFromOpponentGotCalled)
		XCTAssertEqual(mockOutput.opponent, testUser2)
	}
	
	func testStoresLocalVideoTrack() {
		// given
		useFakeCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		
		// then
		XCTAssertNotNil(interactor.localVideoTrack)
	}
	
	func testReceivesRemoteVideoTrack_whenConnectedAndStartedCall() {
		// given
		useFakeCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled)
	}
	
	func testNotifiesPresenterAboutCallServiceOccuredFailure() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.callService(interactor.callService, didChangeState: .Error)
		
		// then
		XCTAssertTrue(mockOutput.didFailCallServiceGotCalled)
	}
	
	func testNotifiesPresenterAboutCallServiceAnswerTimeout() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		interactor.callService(interactor.callService, didAnswerTimeoutForOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveAnswerTimeoutForOpponentGotCalled)
	}
	
	func testNotifiesPresenterAboutSwitchedLocalVideoTrackState() {
		// given  
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(1)
		let initialLocalVideoTrackState = interactor.isLocalVideoTrackEnabled()
		interactor.switchLocalVideoTrackState()
		waitForTimeInterval(1)
		
		// then
		XCTAssertTrue(mockOutput.didSwitchLocalVideoTrackStateGotCalled)
		XCTAssertNotEqual(mockOutput.localVideoTrackState, initialLocalVideoTrackState)
	}
	
	func testNotifiesPresenterAboutDeniedPermission_whenTryingToSwitchLocalVideoTrackWithoutPermission() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(1)
		interactor.switchLocalVideoTrackState()
		waitForTimeInterval(1)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didSwitchLocalVideoTrackStateGotCalled)
	}
	
	func testNotifiesPresenterAboutSwitchedCameraPosition() {
		// given
		useRealCallService()
		permissionsService.authStatus = .authorized
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(1)
		interactor.switchCamera()
		waitForTimeInterval(1)
		
		// then
		XCTAssertTrue(mockOutput.didSwitchCameraPositionGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusDeniedGotCalled)
	}
	
	func testNotifiesPresenterAboutDeniedPermission_whenTryingToSwitchedCameraPositionWithoutPermission() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(1)
		interactor.switchCamera()
		waitForTimeInterval(1)
		
		// then
		XCTAssertFalse(mockOutput.didSwitchCameraPositionGotCalled)
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
	}
	
	func testNotifiesPresenterAboutVideoPermissionsAuthorized() {
		// given
		useRealCallService()
		permissionsService.authStatus = .authorized
		
		// when
		interactor.requestVideoPermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusAuthorizedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusDeniedGotCalled)
	}
	
	func testNotifiesPresenterAboutVideoPermissionsDenied() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.requestVideoPermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusAuthorizedGotCalled)
	}
	
	func testNotifiesPresenterAboutVideoPermissionsNotDetermined_asDenied() {
		// given
		useRealCallService()
		permissionsService.authStatus = .notDetermined
		
		// when
		interactor.requestVideoPermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusAuthorizedGotCalled)
	}
	
	
	// TODO: this case should be handle also
	func DISABLED_testRejectsIncomingCallWhenAnotherCallIsActive() {
		// given
		useRealCallService()
		let undefinedUser = TestsStorage.svuserTest
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		interactor.callService(interactor.callService, didReceiveCallRequestFromOpponent: undefinedUser)
		
		// then
		//XCTAssertTrue(mockOutput.didFailCallServiceGotCalled)
	}
	
	// MARK:- Data Channel Tests
//	func testTriggersDidOpenDataChannelOpen_whenReceivedDataChannel() {
//		// given
//		useFakeCallService()
//		
//		// when
//		interactor.callService.dataChannelEnabled = true
//		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
//		
//		// then
//		XCTAssertTrue(mockOutput.didOpenDataChannelGotCalled)
//	}
//	
//	func testTriggersDidReceiveDataChannelStateReady_whenReceivedDataChannel() {
//		// given
//		useFakeCallService()
//		
//		// when
//		interactor.callService.dataChannelEnabled = true
//		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
//		interactor.requestDataChannelState()
//		
//		// then
//		XCTAssertTrue(mockOutput.didReceiveDataChannelStateReadyGotCalled)
//	}
//	
//	func testTriggersDidReceiveDataChannelStateNotReady_whenNoDataChannel() {
//		// given
//		useRealCallService()
//		
//		// when
//		interactor.callService.dataChannelEnabled = true
//		interactor.requestDataChannelState()
//		
//		// then
//		
//		XCTAssertTrue(mockOutput.didReceiveDataChannelStateNotReadyGotCalled)
//	}
//	
//	func testTriggersDidReceiveInvitationToOpenImageGallery_whenReceivedDataChannelInvitationMessage() {
//		// given
//		useFakeCallService()
//		
//		// when
//		interactor.callService.dataChannelEnabled = true
//		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
//		
//		let invitationData = DataChannelMessages.invitationToOpenImageGallery().dataUsingEncoding(NSUTF8StringEncoding)
//		let invitationMessage = RTCDataBuffer(data: invitationData, isBinary: false)
//		
//		interactor.callService.channel(nil, didReceiveMessageWithBuffer: invitationMessage)
//		
//		// then
//		XCTAssertTrue(mockOutput.didReceiveInvitationToOpenImageGalleryGotCalled)
//	}
//	
//	func testTriggersSendInvitationToOpenImageGallery_whenRequestedImageGallery() {
//		// given
//		useFakeCallService()
//		
//		// when
//		interactor.callService.dataChannelEnabled = true
//		interactor.connectToChatWithUser(testUser, callOpponent: testUser2)
//		
//		guard let fakeCallService = interactor.callService as? FakeCallService else {
//			XCTFail("We have to use fakeCallService here")
//			return
//		}
//		
//		fakeCallService.setHasActiveCall(true)
//		
//		interactor.sendInvitationMessageAndOpenImageGallery()
//		
//		// then
//		XCTAssertTrue(mockOutput.didSendInvitationToOpenImageGalleryGotCalled)
//	}
	
	class MockPresenter: NSObject,  VideoCallStoryInteractorOutput {
		var connectedToChatUser: SVUser?
		var opponent: SVUser?
		
		var didHangupGotCalled = false
		var didReceiveHangupFromOpponentGotCalled = false
		var didReceiveRejectFromOpponentGotCalled = false
		var didReceiveAnswerTimeoutForOpponentGotCalled = false
		
		var didFailToConnectToChatGotCalled = false
		var didFailCallServiceGotCalled = false
		
		var didSetLocalCaptureSessionGotCalled = false
		var didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled = false
		var didOpenDataChannelGotCalled = false
		var didReceiveDataChannelStateReadyGotCalled = false
		var didReceiveDataChannelStateNotReadyGotCalled = false
		var didReceiveInvitationToOpenImageGalleryGotCalled = false
		var didSendInvitationToOpenImageGalleryGotCalled = false
		
		var didStartDialingOpponentGotCalled = false
		var didReceiveAnswerFromOpponentGotCalled = false
		var didSendPushNotificationAboutNewCallToOpponentGotCalled = false
		var didSwitchCameraPositionGotCalled = false
		var didSwitchLocalVideoTrackStateGotCalled = false
		var localVideoTrackState: Bool?

		// Permissions
		var didReceiveVideoStatusAuthorizedGotCalled = false
		var didReceiveVideoStatusDeniedGotCalled = false
		
		func didHangup() {
			didHangupGotCalled = true
		}
		
		func didReceiveHangupFromOpponent(opponent: SVUser) {
			didReceiveHangupFromOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didReceiveRejectFromOpponent(opponent: SVUser) {
			didReceiveRejectFromOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didReceiveAnswerTimeoutForOpponent(opponent: SVUser) {
			didReceiveAnswerTimeoutForOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didFailToConnectToChat() {
			
		}
		
		func didFailCallService() {
			didFailCallServiceGotCalled = true
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

		func didStartDialingOpponent(opponent: SVUser) {
			self.opponent = opponent
			didStartDialingOpponentGotCalled = true
		}
		
		func didReceiveAnswerFromOpponent(opponent: SVUser) {
			self.opponent = opponent
			didReceiveAnswerFromOpponentGotCalled = true
		}
		
		func didSendPushNotificationAboutNewCallToOpponent(opponent: SVUser) {
			didSendPushNotificationAboutNewCallToOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didSwitchCameraPosition(backCamera: Bool) {
			didSwitchCameraPositionGotCalled = true
		}
		
		func didSwitchLocalVideoTrackState(enabled: Bool) {
			localVideoTrackState = enabled
			didSwitchLocalVideoTrackStateGotCalled = true
		}
		
		func didReceiveVideoStatusAuthorized() {
			didReceiveVideoStatusAuthorizedGotCalled = true
		}
		
		func didReceiveVideoStatusDenied() {
			didReceiveVideoStatusDeniedGotCalled = true
		}
	}
}
