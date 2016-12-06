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

class VideoCallStoryPresenterTest: XCTestCase {

	var presenter: VideoCallStoryPresenter!
	var mockInteractor: MockInteractor!
	var mockRouter: MockRouter!
	var mockView: MockViewController!
	
	let testUser = TestsStorage.svuserRealUser1()
	let testUser2 = TestsStorage.svuserRealUser2()
	
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
		presenter.connectToChatWithUser(testUser, callOpponent: testUser2)
		
		// then
		XCTAssertTrue(mockInteractor.connectToChatWithUserGotCalled)
		XCTAssertEqual(mockInteractor.connectedUser, testUser)
		XCTAssertEqual(mockInteractor.opponent, testUser2)
	}
	
	// MARK: - Testing methods of VideoCallStoryViewOutput
	func testPresenterHandlesViewReadyEvent() {
		// when
		presenter.viewIsReady()
		
		// then
		XCTAssertTrue(mockView.setupInitialStateGotCalled)
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
	func testPresenterHandlesDidConnectToChatWithTestUser() {
		// when
		presenter.didConnectToChatWithUser(testUser)
		
		// then
		XCTAssertTrue(mockView.configureViewWithUserGotCalled)
	}
	
	func testPresenterHandlesConnectionError() {
		// when
		presenter.didFailToConnectToChat()
		
		// then
		XCTAssertTrue(mockView.showErrorConnectGotCalled)
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
		
		// then
		XCTAssertTrue(mockView.showHangupGotCalled)
	}
	
	func testPresenterHandlesOpponentHangupAndCallsViewShowOpponentHangup() {
		// when
		presenter.didReceiveHangupFromOpponent(testUser2)
		
		// then
		XCTAssertTrue(mockView.showOpponentHangupGotCalled)
	}
	
	func testPresenterHandlesLocalVideoTrack() {
		// given
		let localCaptureSession = AVCaptureSession()
		
		// when
		presenter.didSetLocalCaptureSession(localCaptureSession)
		
		// then
		XCTAssertTrue(mockView.setLocalVideoCaptureSessionGotCalled)
		XCTAssertEqual(localCaptureSession, mockView.localCaptureSession)
	}
	
	func testPresenterHandlesRemoteVideoTrack() {
		// when
		presenter.didReceiveRemoteVideoTrackWithConfigurationBlock(nil)
		
		// then
		XCTAssertTrue(mockView.configureRemoteVideoViewWithBlockGotCalled)
	}
	
	func testPresenterHandlesDataChannelNotReadyState() {
		// when
		presenter.didReceiveDataChannelStateNotReady()
		
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
	
	
    class MockInteractor: VideoCallStoryInteractorInput {
		var connectedUser: SVUser?
		var opponent: SVUser?
		
		var connectToChatWithUserGotCalled = false
		var startCallWithOpponentGotCalled = false
		var acceptCallFromOpponentGotCalled = false
		var hangupGotCalled = false
		var requestDataChannelStateGotCalled = false
		var sendInvitationMessageAndOpenImageGalleryGotCalled = false
		var switchCameraGotCalled = false
		var switchAudioRouteGotCalled = false
		
		func connectToChatWithUser(user: SVUser, callOpponent opponent: SVUser?) {
			self.connectedUser = user
			self.opponent = opponent
			connectToChatWithUserGotCalled = true
		}
		
		func startCallWithOpponent(opponent: SVUser) {
			self.opponent = opponent
			startCallWithOpponentGotCalled = true
		}
		
		func acceptCallFromOpponent(opponent: SVUser) {
			self.opponent = opponent
			acceptCallFromOpponentGotCalled = true
		}
		
		func hangup() {
			hangupGotCalled = true
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
		var showHangupGotCalled = false
		var showOpponentHangupGotCalled = false
		var showErrorConnectGotCalled = false
		var showErrorDataChannelNotReadyGotCalled = false
		var localCaptureSession: AVCaptureSession?
		var setLocalVideoCaptureSessionGotCalled = false
		var configureRemoteVideoViewWithBlockGotCalled = false
		
        func setupInitialState() {
			setupInitialStateGotCalled = true
        }
		
		func configureViewWithUser(user: SVUser) {
			configureViewWithUserGotCalled = true
		}
		
		func showHangup() {
			showHangupGotCalled = true
		}
		
		func showOpponentHangup() {
			showOpponentHangupGotCalled = true
		}
		
		func showErrorConnect() {
			showErrorConnectGotCalled = true
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
    }
}
