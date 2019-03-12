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
		let callService = FakeCallService()
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
	
	func testSendsPushNotificationToOpponentAboutNewCall_whenDialingIsStarted() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		// time to apply local SDP and start dialing, dialing must call send push event
		waitForTimeInterval(50)
		
		// then
		//XCTAssertTrue(mockOutput.didSetLocalCaptureSessionGotCalled)
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
		(interactor.callService as! FakeCallService).shouldBeConnected = true
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(interactor.localVideoTrack != nil)
	}
	
	func testReceivesRemoteVideoTrack_whenConnectedAndStartedCall() {
		// given
		useFakeCallService()
		(interactor.callService as! FakeCallService).shouldBeConnected = true
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled)
	}

	func testReceivesLocalVideoTrack_whenConnectedAndStartedCall() {
		// given
		useFakeCallService()
		(interactor.callService as! FakeCallService).shouldBeConnected = true

		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)

		// then
		XCTAssertTrue(mockOutput.didReceiveLocalVideoTrackWithConfigurationBlockGotCalled)
	}

	func testHandlesCameraPositionSwitch_whenConnectedAndStartedCall() {
		// given
		useFakeCallService()
		(interactor.callService as! FakeCallService).shouldBeConnected = true

		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		interactor.switchCamera()
		waitForTimeInterval(150)

		// then
		XCTAssertTrue(mockOutput.willSwitchDevicePositionWithConfigurationBlockGotCalled)
	}

	func testNotifiesPresenterAboutCallServiceOccuredFailure() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.callService(interactor.callService, didChangeState: .error)
		
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
		waitForTimeInterval(50)
		let initialLocalVideoTrackState = interactor.isLocalVideoTrackEnabled()
		interactor.switchLocalVideoTrackState()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockOutput.didSwitchLocalVideoTrackStateGotCalled)
		XCTAssertNotNil(mockOutput.localVideoTrackState)
		XCTAssertNotEqual(mockOutput.localVideoTrackState, initialLocalVideoTrackState)
	}
	
	func testNotifiesPresenterAboutDeniedPermission_whenTryingToSwitchLocalVideoTrackStateWithoutPermission() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		interactor.switchLocalVideoTrackState()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didSwitchLocalVideoTrackStateGotCalled)
	}
	
	func testNotifiesPresenterAboutSwitchedLocalAudioTrackState() {
		// given
		useRealCallService()
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		let initialLocalAudioTrackState = interactor.isLocalAudioTrackEnabled()
		interactor.switchLocalAudioTrackState()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockOutput.didSwitchLocalAudioTrackStateGotCalled)
		XCTAssertNotNil(mockOutput.localAudioTrackState)
		XCTAssertNotEqual(mockOutput.localAudioTrackState, initialLocalAudioTrackState)
	}
	
	func testNotifiesPresenterAboutDeniedPermission_whenTryingToSwitchLocalAudioTrackStateWithoutPermission() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		interactor.switchLocalAudioTrackState()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveMicrophoneStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didSwitchLocalAudioTrackStateGotCalled)
	}
	
	func testNotifiesPresenterAboutSwitchedCameraPosition() {
		// given
		useRealCallService()
		permissionsService.authStatus = .authorized
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		interactor.switchCamera()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockOutput.didSwitchCameraPositionGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusDeniedGotCalled)
	}
	
	func testNotifiesPresenterAboutDeniedPermission_whenTryingToSwitchCameraPositionWithoutPermission() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.callService.connectWithUser(testUser, completion: nil)
		interactor.startCallWithOpponent(testUser2)
		waitForTimeInterval(50)
		interactor.switchCamera()
		waitForTimeInterval(50)
		
		// then
		XCTAssertFalse(mockOutput.didSwitchCameraPositionGotCalled)
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
	}
	
	// MARK: - Video permissions
	
	func testNotifiesPresenterAboutVideoPermissionAuthorized() {
		// given
		useRealCallService()
		permissionsService.authStatus = .authorized
		
		// when
		interactor.requestVideoPermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusAuthorizedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusDeniedGotCalled)
	}
	
	func testNotifiesPresenterAboutVideoPermissionDenied() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.requestVideoPermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusAuthorizedGotCalled)
	}
	
	func testNotifiesPresenterAboutVideoPermissionNotDetermined_asDenied() {
		// given
		useRealCallService()
		permissionsService.authStatus = .notDetermined
		
		// when
		interactor.requestVideoPermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveVideoStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveVideoStatusAuthorizedGotCalled)
	}
	
	// MARK: - Microphone permissions
	
	func testNotifiesPresenterAboutMicrophonePermissionAuthorized() {
		// given
		useRealCallService()
		permissionsService.authStatus = .authorized
		
		// when
		interactor.requestMicrophonePermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveMicrophoneStatusAuthorizedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveMicrophoneStatusDeniedGotCalled)
	}
	
	func testNotifiesPresenterAboutMicrophonePermissionsDenied() {
		// given
		useRealCallService()
		permissionsService.authStatus = .denied
		
		// when
		interactor.requestMicrophonePermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveMicrophoneStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveMicrophoneStatusAuthorizedGotCalled)
	}
	
	func testNotifiesPresenterAboutMicrophonePermissionsNotDetermined_asDenied() {
		// given
		useRealCallService()
		permissionsService.authStatus = .notDetermined
		
		// when
		interactor.requestMicrophonePermissionStatus()
		
		// then
		XCTAssertTrue(mockOutput.didReceiveMicrophoneStatusDeniedGotCalled)
		XCTAssertFalse(mockOutput.didReceiveMicrophoneStatusAuthorizedGotCalled)
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
		var didReceiveLocalVideoTrackWithConfigurationBlockGotCalled = false
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
		
		var didSwitchLocalAudioTrackStateGotCalled = false
		var localAudioTrackState: Bool?

		// Permissions
		var didReceiveVideoStatusAuthorizedGotCalled = false
		var didReceiveVideoStatusDeniedGotCalled = false
		
		var didReceiveMicrophoneStatusAuthorizedGotCalled = false
		var didReceiveMicrophoneStatusDeniedGotCalled = false

		var willSwitchDevicePositionWithConfigurationBlockGotCalled = false
		
		func didHangup() {
			didHangupGotCalled = true
		}
		
		func didReceiveHangupFromOpponent(_ opponent: SVUser) {
			didReceiveHangupFromOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didReceiveRejectFromOpponent(_ opponent: SVUser) {
			didReceiveRejectFromOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didReceiveAnswerTimeoutForOpponent(_ opponent: SVUser) {
			didReceiveAnswerTimeoutForOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didFailToConnectToChat() {
			
		}
		
		func didFailCallService() {
			didFailCallServiceGotCalled = true
		}
		
		func didSetLocalCaptureSession(_ localCaptureSession: AVCaptureSession) {
			didSetLocalCaptureSessionGotCalled = true
		}
		
		func didReceiveRemoteVideoTrackWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?) {
			block?(nil)
			didReceiveRemoteVideoTrackWithConfigurationBlockGotCalled = true
		}
		func didReceiveLocalVideoTrackWithConfigurationBlock(_ block: ((RenderableView?) -> Void)?) {
			block?(nil)
			didReceiveLocalVideoTrackWithConfigurationBlockGotCalled = true
		}
		func willSwitchDevicePositionWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?) {
			block?(nil)
			willSwitchDevicePositionWithConfigurationBlockGotCalled = true
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

		func didStartDialingOpponent(_ opponent: SVUser) {
			self.opponent = opponent
			didStartDialingOpponentGotCalled = true
		}
		
		func didReceiveAnswerFromOpponent(_ opponent: SVUser) {
			self.opponent = opponent
			didReceiveAnswerFromOpponentGotCalled = true
		}
		
		func didSendPushNotificationAboutNewCallToOpponent(_ opponent: SVUser) {
			didSendPushNotificationAboutNewCallToOpponentGotCalled = true
			self.opponent = opponent
		}
		
		func didSwitchCameraPosition(_ backCamera: Bool) {
			didSwitchCameraPositionGotCalled = true
		}
		
		func didSwitchLocalVideoTrackState(_ enabled: Bool) {
			localVideoTrackState = enabled
			didSwitchLocalVideoTrackStateGotCalled = true
		}
		
		func didSwitchLocalAudioTrackState(_ enabled: Bool) {
			localAudioTrackState = enabled
			didSwitchLocalAudioTrackStateGotCalled = true
		}
		
		func didReceiveVideoStatusAuthorized() {
			didReceiveVideoStatusAuthorizedGotCalled = true
		}
		
		func didReceiveVideoStatusDenied() {
			didReceiveVideoStatusDeniedGotCalled = true
		}
		
		func didReceiveMicrophoneStatusAuthorized() {
			didReceiveMicrophoneStatusAuthorizedGotCalled = true
		}
		
		func didReceiveMicrophoneStatusDenied() {
			didReceiveMicrophoneStatusDeniedGotCalled = true
		}
	}
}
