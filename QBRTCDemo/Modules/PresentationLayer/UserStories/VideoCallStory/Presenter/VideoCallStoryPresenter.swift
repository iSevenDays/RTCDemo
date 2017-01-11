//
//  VideoCallStoryPresenter.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

@objc class VideoCallStoryPresenter: NSObject {
	weak var view: VideoCallStoryViewInput?
	var interactor: VideoCallStoryInteractorInput!
	var router: VideoCallStoryRouterInput!
}

extension VideoCallStoryPresenter: VideoCallStoryModuleInput {
	func startCallWithOpponent(opponent: SVUser) {
		interactor.startCallWithOpponent(opponent)
	}
	
	func acceptCallFromOpponent(opponent: SVUser) {
		interactor.acceptCallFromOpponent(opponent)
	}
}

extension VideoCallStoryPresenter: VideoCallStoryViewOutput {
	func viewIsReady() {
		view?.setupInitialState()
		interactor.requestVideoPermissionStatus()
		interactor.requestMicrophonePermissionStatus()
	}
	
	func didTriggerHangupButtonTapped() {
		interactor.hangup()
	}
	
	func didTriggerDataChannelButtonTapped() {
		interactor.sendInvitationMessageAndOpenImageGallery()
	}
	
	func didTriggerCloseButtonTapped() {
		router.unwindToChatsUserStory()
	}
	
	func didTriggerSwitchCameraButtonTapped() {
		interactor.switchCamera()
	}
	
	func didTriggerSwitchAudioRouteButtonTapped() {
		interactor.switchAudioRoute()
	}
	
	func didTriggerSwitchLocalVideoTrackStateButtonTapped() {
		interactor.switchLocalVideoTrackState()
	}
	
	func didTriggerMicrophoneButtonTapped() {
		interactor.switchLocalAudioTrackState()
	}
}

extension VideoCallStoryPresenter: VideoCallStoryInteractorOutput {
	
	func didHangup() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showHangup()
		}
	}
	
	func didReceiveHangupFromOpponent(opponent: SVUser) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showOpponentHangup()
		}
	}
	
	func didReceiveRejectFromOpponent(opponent: SVUser) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showOpponentReject()
		}
	}
	
	func didReceiveAnswerTimeoutForOpponent(opponent: SVUser) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showOpponentAnswerTimeout()
		}
	}
	
	func didFailToConnectToChat() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showErrorConnect()
		}
	}
	
	func didFailCallService() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showErrorCallServiceDisconnected()
		}
	}
	
	func didSetLocalCaptureSession(localCaptureSession: AVCaptureSession) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.setLocalVideoCaptureSession(localCaptureSession)
		}
	}
	
	func didReceiveRemoteVideoTrackWithConfigurationBlock(block: ((renderer: RTCEAGLVideoView?) -> Void)?) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.configureRemoteVideoViewWithBlock(block)
		}
	}
	
	func didReceiveDataChannelStateReady() {
		// do nothing
	}
	
	func didReceiveInvitationToOpenImageGallery() {
		router.openImageGallery()
	}
	
	func didSendInvitationToOpenImageGallery() {
		router.openImageGallery()
	}
	
	func didReceiveDataChannelStateNotReady() {
		dispatch_async(dispatch_get_main_queue(), { [view] in
			view?.showErrorDataChannelNotReady()
			})
	}
	
	func didStartDialingOpponent(opponent: SVUser) {
		dispatch_async(dispatch_get_main_queue(), { [view] in
			view?.showStartDialingOpponent(opponent)
			})
	}
	
	func didReceiveAnswerFromOpponent(opponent: SVUser) {
		dispatch_async(dispatch_get_main_queue(), { [view] in
			view?.showReceivedAnswerFromOpponent(opponent)
			})
	}
	
	// TODO: Add Tests
	func didSwitchCameraPosition(backCamera: Bool) {
		dispatch_async(dispatch_get_main_queue(), { [view] in
			view?.showCameraPosition(backCamera)
		})
	}
	
	func didSwitchLocalVideoTrackState(enabled: Bool) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showLocalVideoTrackEnabled(enabled)
		}
	}
	
	func didSwitchLocalAudioTrackState(enabled: Bool) {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showLocalAudioTrackEnabled(enabled)
		}
	}
	
	func didReceiveVideoStatusAuthorized() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showLocalVideoTrackAuthorized()
		}
	}
	
	func didReceiveVideoStatusDenied() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showLocalVideoTrackDenied()
		}
	}
	
	func didReceiveMicrophoneStatusAuthorized() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showMicrophoneAuthorized()
		}
	}
	
	func didReceiveMicrophoneStatusDenied() {
		dispatch_async(dispatch_get_main_queue()) { [view] in
			view?.showMicrophoneDenied()
		}
	}
	
	func didSendPushNotificationAboutNewCallToOpponent(opponent: SVUser) {
		
	}
	
	func didOpenDataChannel() {
		
	}
}
