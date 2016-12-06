//
//  VideoCallStoryPresenter.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

@objc class VideoCallStoryPresenter: NSObject {
	weak var view: VideoCallStoryViewInput!
	var interactor: VideoCallStoryInteractorInput!
	var router: VideoCallStoryRouterInput!
}

extension VideoCallStoryPresenter: VideoCallStoryModuleInput {
	func connectToChatWithUser(user: SVUser, callOpponent opponent: SVUser?) {
		interactor.connectToChatWithUser(user, callOpponent: opponent)
	}
	
	func acceptCallFromOpponent(opponent: SVUser) {
		interactor.acceptCallFromOpponent(opponent)
	}
}

extension VideoCallStoryPresenter: VideoCallStoryViewOutput {
	func viewIsReady() {
		view.setupInitialState()
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
	
	func didTriggerSwitchButtonTapped() {
		interactor.switchCamera()
	}
}

extension VideoCallStoryPresenter: VideoCallStoryInteractorOutput {
	func didConnectToChatWithUser(user: SVUser) {
		view.configureViewWithUser(user)
	}
	
	func didHangup() {
		view.showHangup()
	}
	
	func didReceiveHangupFromOpponent(opponent: SVUser) {
		view.showOpponentHangup()
	}
	
	func didFailToConnectToChat() {
		view.showErrorConnect()
	}
	
	func didSetLocalCaptureSession(localCaptureSession: AVCaptureSession) {
		view.setLocalVideoCaptureSession(localCaptureSession)
	}
	
	func didReceiveRemoteVideoTrackWithConfigurationBlock(block: ((renderer: RTCEAGLVideoView?) -> Void)?) {
		view.configureRemoteVideoViewWithBlock(block)
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
		view.showErrorDataChannelNotReady()
	}
	
	func didOpenDataChannel() {
		
	}
}
