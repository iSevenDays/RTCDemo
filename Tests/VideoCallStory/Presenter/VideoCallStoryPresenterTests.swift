//
//  VideoCallStoryPresenterTests.swift
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

class VideoCallStoryPresenterTest: BaseTestCase {

	var presenter: VideoCallStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
	let testUser = TestsStorage.svuserRealUser1
	let testUser2 = TestsStorage.svuserRealUser2
	
    override func setUp() {
        super.setUp()
		presenter = VideoCallStoryPresenter()
		
		mockInteractor = MockInteractor()
		
		mockRouter = MockRouter()
		mockView = MockViewController()
		
		presenter.interactor = mockInteractor
		presenter.router = mockRouter
		presenter.view = mockView
    }

    override func tearDown() {
        presenter = nil
		mockView = nil
		mockRouter = nil
		mockInteractor = nil
		
        super.tearDown()
    }

	// MARK: - Testing methods of VideoCallStoryModuleInput
	func testPresenterHandlesStartCallWithUserEventFromModuleInput() {
		// when
		presenter.startCallWithOpponent(testUser2)
		
		// then
		XCTAssertEqual(mockInteractor.connectedUser, nil)
		XCTAssertEqual(mockInteractor.opponent, testUser2)
	}
	
	// MARK: - Testing methods of VideoCallStoryViewOutput
	func testPresenterHandlesViewReadyEvent() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockView.setupInitialStateGotCalled)
		XCTAssertTrue(mockInteractor.requestVideoPermissionStatusGotCalled)
		XCTAssertTrue(mockInteractor.requestMicrophonePermissionStatusGotCalled)
	}
	
	func testPresenterHandlesHangupButtonTapped() {
		// when
		presenter.didTriggerHangupButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.hangupGotCalled)
	}
	
	func testThatPresenterHandlesDataChannelButtonTapped_andOpenImageGallery() {
		// when
		presenter.didTriggerDataChannelButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.sendInvitationMessageAndOpenImageGalleryGotCalled)
	}
	
	// MARK: - Testing methods of VideoCallStoryInteractorOutput
	
	func testPresenterHandlesChatConnectionError() {
		// when
		presenter.didFailToConnectToChat()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showErrorConnectGotCalled)
	}
	
	func testPresenterHandlesCallServiceError() {
		// when
		presenter.didFailCallService()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showErrorCallServiceDisconnectedGotCalled)
	}
	
	func testPresenterHandlesCloseActionAndCallsRouterUnwindSegue() {
		// when
		presenter.didTriggerCloseButtonTapped()
		
		// then
		XCTAssertTrue(mockRouter.unwindToChatsUserStoryGotCalled)
	}
	
	func testPresenterHandlesHangupAndCallsViewShowHangup() {
		// when
		presenter.didHangup()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showHangupGotCalled)
	}
	
	func testPresenterHandlesOpponentHangupAndCallsViewShowOpponentHangup() {
		// when
		presenter.didReceiveHangupFromOpponent(testUser2)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showOpponentHangupGotCalled)
	}
	
	func testPresenterHandlesOpponentRejectAndCallsViewShowOpponentReject() {
		// when
		presenter.didReceiveRejectFromOpponent(testUser2)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showOpponentRejectGotCalled)
	}
	
	func testPresenterHandlesLocalVideoTrack() {
		// given
		let localCaptureSession = AVCaptureSession()
		
		// when
		presenter.didSetLocalCaptureSession(localCaptureSession)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.setLocalVideoCaptureSessionGotCalled)
		XCTAssertEqual(localCaptureSession, mockView.localCaptureSession)
	}
	
	func testPresenterHandlesRemoteVideoTrack() {
		// when
		presenter.didReceiveRemoteVideoTrackWithConfigurationBlock(nil)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.configureRemoteVideoViewWithBlockGotCalled)
	}
	
	func testPresenterHandlesDataChannelNotReadyState() {
		// when
		presenter.didReceiveDataChannelStateNotReady()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showErrorDataChannelNotReadyGotCalled)
	}
	
	func testPresenterHandlesIncomingDataChannelInvitationToOpenImageGallery_andOpensImageGallery() {
		// when
		presenter.didReceiveInvitationToOpenImageGallery()
		
		// then
		XCTAssertTrue(mockRouter.openImageGalleryGotCalled)
	}
	
	func testPresenterHandlesOutgoingDataChannelInvitationToOpenImageGallery_andOpensImageGallery() {
		// when
		presenter.didSendInvitationToOpenImageGallery()
		
		// then
		XCTAssertTrue(mockRouter.openImageGalleryGotCalled)
	}
	
	func testPresenterSwitchesCamera() {
		// when
		presenter.didTriggerSwitchCameraButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.switchCameraGotCalled)
	}
	
	func testPresenterSwitchesAudioRoute() {
		// when
		presenter.didTriggerSwitchAudioRouteButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.switchAudioRouteGotCalled)
	}
	
	func testPresenterSwitchesLocalVideoTrackState() {
		// when
		presenter.didTriggerSwitchLocalVideoTrackStateButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.switchLocalVideoTrackStateGotCalled)
	}
	
	func testPresenterSwitchesLocalAudioTrackState() {
		// when
		presenter.didTriggerMicrophoneButtonTapped()
		
		// then
		XCTAssertTrue(mockInteractor.switchLocalAudioTrackStateGotCalled)
	}
	
	func testPresenterHandlesDialingOpponent() {
		// when
		presenter.didStartDialingOpponent(testUser2)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showStartDialingOpponentGotCalled)
	}
	
	func testPresenterHandlesReceivedAnswerFromOpponent() {
		// when
		presenter.didReceiveAnswerFromOpponent(testUser2)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showReceivedAnswerFromOpponentGotCalled)
	}
	
	// Camera permissions
	func testPresenterNotifiesViewAboutAuthorizedCamera() {
		// when
		presenter.didReceiveVideoStatusAuthorized()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showLocalVideoTrackAuthorizedGotCalled)
	}
	
	func testPresenterNotifiesViewAboutDeniedCamera() {
		// when
		presenter.didReceiveVideoStatusDenied()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showLocalVideoTrackDeniedGotCalled)
	}
	
	// Microphone permissions
	func testPresenterNotifiesViewAboutAuthorizedMicrophone() {
		// when
		presenter.didReceiveMicrophoneStatusAuthorized()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showMicrophoneAuthorizedGotCalled)
	}
	
	func testPresenterNotifiesViewAboutDeniedMicrophone() {
		// when
		presenter.didReceiveMicrophoneStatusDenied()
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showMicrophoneDeniedGotCalled)
	}
	
	// Video track enabled/disabled
	func testPresenterNotifiesViewAboutVideoTrackStateChange() {
		// when
		presenter.didSwitchLocalVideoTrackState(true)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showLocalVideoTrackEnabledGotCalled)
	}
	
	// Audio track(microphone) enabled/disabled
	func testPresenterNotifiesViewAboutAudioTrackStateChange() {
		// when
		presenter.didSwitchLocalAudioTrackState(true)
		waitForTimeInterval(50)
		
		// then
		XCTAssertTrue(mockView.showLocalAudioTrackEnabledGotCalled)
	}
	
    class MockInteractor: VideoCallStoryInteractorInput {
		var connectedUser: SVUser?
		var opponent: SVUser?
		
		var startCallWithOpponentGotCalled = false
		var acceptCallFromOpponentGotCalled = false
		var showStartDialingOpponentGotCalled = false
		var hangupGotCalled = false
		var requestDataChannelStateGotCalled = false
		var sendInvitationMessageAndOpenImageGalleryGotCalled = false
		var switchCameraGotCalled = false
		var switchAudioRouteGotCalled = false
		
		var switchLocalVideoTrackStateGotCalled = false
		var switchLocalAudioTrackStateGotCalled = false
		
		// Permissions
		var requestVideoPermissionStatusGotCalled = false
		var requestMicrophonePermissionStatusGotCalled = false
		
		func startCallWithOpponent(opponent: SVUser) {
			self.opponent = opponent
			startCallWithOpponentGotCalled = true
		}
		
		func acceptCallFromOpponent(opponent: SVUser) {
			self.opponent = opponent
			acceptCallFromOpponentGotCalled = true
		}
		
		func showStartDialingOpponent(opponent: SVUser) {
			self.opponent = opponent
			showStartDialingOpponentGotCalled = true
		}
		
		func hangup() {
			hangupGotCalled = true
		}
		
		func requestVideoPermissionStatus() {
			requestVideoPermissionStatusGotCalled = true
		}
		
		func requestMicrophonePermissionStatus() {
			requestMicrophonePermissionStatusGotCalled = true
		}
		
		func requestDataChannelState() {
			requestDataChannelStateGotCalled = true
		}
		
		func sendInvitationMessageAndOpenImageGallery() {
			sendInvitationMessageAndOpenImageGalleryGotCalled = true
		}
		
		func switchCamera() {
			switchCameraGotCalled = true
		}
		
		func switchAudioRoute() {
			switchAudioRouteGotCalled = true
		}
		
		func switchLocalVideoTrackState() {
			switchLocalVideoTrackStateGotCalled = true
		}
		
		func switchLocalAudioTrackState() {
			switchLocalAudioTrackStateGotCalled = true
		}
    }

    class MockRouter: VideoCallStoryRouterInput {
		var openImageGalleryGotCalled = false
		var unwindToChatsUserStoryGotCalled = false
		func openImageGallery() {
			openImageGalleryGotCalled = true
		}
		
		func unwindToChatsUserStory() {
			unwindToChatsUserStoryGotCalled = true
		}
    }

    class MockViewController: VideoCallStoryViewInput {

		var setupInitialStateGotCalled = false
		var configureViewWithUserGotCalled = false
		var showStartDialingOpponentGotCalled = false
		var showReceivedAnswerFromOpponentGotCalled = false
		var showHangupGotCalled = false
		var showOpponentHangupGotCalled = false
		var showOpponentRejectGotCalled = false
		var showOpponentAnswerTimeoutGotCalled = false
		var showErrorConnectGotCalled = false
		var showErrorCallServiceDisconnectedGotCalled = false
		var showErrorDataChannelNotReadyGotCalled = false
		var localCaptureSession: AVCaptureSession?
		var setLocalVideoCaptureSessionGotCalled = false
		var configureRemoteVideoViewWithBlockGotCalled = false
		
		var showLocalVideoTrackEnabledGotCalled = false
		var showLocalAudioTrackEnabledGotCalled = false
		
		var showLocalVideoTrackAuthorizedGotCalled = false
		var showLocalVideoTrackDeniedGotCalled = false
		
		var showMicrophoneAuthorizedGotCalled = false
		var showMicrophoneDeniedGotCalled = false
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func configureViewWithUser(user: SVUser) {
			configureViewWithUserGotCalled = true
		}
		
		func showStartDialingOpponent(opponent: SVUser) {
			showStartDialingOpponentGotCalled = true
		}
		
		func showReceivedAnswerFromOpponent(opponent: SVUser) {
			showReceivedAnswerFromOpponentGotCalled = true
		}
		
		func showHangup() {
			showHangupGotCalled = true
		}
		
		func showOpponentHangup() {
			showOpponentHangupGotCalled = true
		}
		
		func showOpponentReject() {
			showOpponentRejectGotCalled = true
		}
		
		func showOpponentAnswerTimeout() {
			showOpponentAnswerTimeoutGotCalled = true
		}
		
		func showErrorConnect() {
			showErrorConnectGotCalled = true
		}
		
		func showErrorCallServiceDisconnected() {
			showErrorCallServiceDisconnectedGotCalled = true
		}
		
		func showErrorDataChannelNotReady() {
			showErrorDataChannelNotReadyGotCalled = true
		}
		
		func setLocalVideoCaptureSession(captureSession: AVCaptureSession) {
			localCaptureSession = captureSession
			setLocalVideoCaptureSessionGotCalled = true
		}
		
		func configureRemoteVideoViewWithBlock(block: ((RTCEAGLVideoView?) -> Void)?) {
			configureRemoteVideoViewWithBlockGotCalled = true
		}
		
		func showLocalVideoTrackEnabled(enabled: Bool) {
			showLocalVideoTrackEnabledGotCalled = true
		}
		
		func showLocalAudioTrackEnabled(enabled: Bool) {
			showLocalAudioTrackEnabledGotCalled = true
		}
		
		func showLocalVideoTrackAuthorized() {
			showLocalVideoTrackAuthorizedGotCalled = true
		}
		
		func showLocalVideoTrackDenied() {
			showLocalVideoTrackDeniedGotCalled = true
		}
		
		func showMicrophoneAuthorized() {
			showMicrophoneAuthorizedGotCalled = true
		}
		
		func showMicrophoneDenied() {
			showMicrophoneDeniedGotCalled = true
		}
		
		func showCameraPosition(backCamera: Bool) {
			
		}
		
    }
}
