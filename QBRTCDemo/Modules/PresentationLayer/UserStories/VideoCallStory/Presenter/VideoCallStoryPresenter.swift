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
	func startCallWithOpponent(_ opponent: SVUser) {
		interactor.startCallWithOpponent(opponent)
	}
	
	func acceptCallFromOpponent(_ opponent: SVUser) {
		DispatchQueue.main.async { [view] in
			view?.showCurrentUserAcceptedCallFromOpponent(opponent)
		}
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
		DispatchQueue.main.async { [view] in
			view?.showHangup()
		}
	}
	
	func didReceiveHangupFromOpponent(_ opponent: SVUser) {
		DispatchQueue.main.async { [view] in
			view?.showOpponentHangup()
		}
	}
	
	func didReceiveRejectFromOpponent(_ opponent: SVUser) {
		DispatchQueue.main.async { [view] in
			view?.showOpponentReject()
		}
	}
	
	func didReceiveAnswerTimeoutForOpponent(_ opponent: SVUser) {
		DispatchQueue.main.async { [view] in
			view?.showOpponentAnswerTimeout()
		}
	}
	
	func didFailToConnectToChat() {
		DispatchQueue.main.async { [view] in
			view?.showErrorConnect()
		}
	}
	
	func didFailCallService() {
		DispatchQueue.main.async { [view] in
			view?.showErrorCallServiceDisconnected()
		}
	}
	
	func didReceiveLocalVideoTrackWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?) {
		DispatchQueue.main.async { [view] in
			view?.configureLocalVideoViewWithBlock(block)
		}
	}
	
	func didReceiveRemoteVideoTrackWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?) {
		DispatchQueue.main.async { [view] in
			view?.configureRemoteVideoViewWithBlock(block)
		}
	}

	func willSwitchDevicePositionWithConfigurationBlock(_ block: ((RenderableView?) -> Void)?) {
		DispatchQueue.main.async { [view] in
			view?.configureLocalVideoViewWithBlock(block)
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
		DispatchQueue.main.async(execute: { [view] in
			view?.showErrorDataChannelNotReady()
			})
	}
	
	func didStartDialingOpponent(_ opponent: SVUser) {
		DispatchQueue.main.async(execute: { [view] in
			view?.showStartDialingOpponent(opponent)
			})
	}
	
	func didReceiveAnswerFromOpponent(_ opponent: SVUser) {
		DispatchQueue.main.async(execute: { [view] in
			view?.showReceivedAnswerFromOpponent(opponent)
			})
	}
	
	// TODO: Add Tests
	func didSwitchCameraPosition(_ backCamera: Bool) {
		DispatchQueue.main.async(execute: { [view] in
			view?.showCameraPosition(backCamera)
		})
	}
	
	func didSwitchLocalVideoTrackState(_ enabled: Bool) {
		DispatchQueue.main.async { [view] in
			view?.showLocalVideoTrackEnabled(enabled)
		}
	}
	
	func didSwitchLocalAudioTrackState(_ enabled: Bool) {
		DispatchQueue.main.async { [view] in
			view?.showLocalAudioTrackEnabled(enabled)
		}
	}
	
	func didReceiveVideoStatusAuthorized() {
		DispatchQueue.main.async { [view] in
			view?.showLocalVideoTrackAuthorized()
		}
	}
	
	func didReceiveVideoStatusDenied() {
		DispatchQueue.main.async { [view] in
			view?.showLocalVideoTrackDenied()
		}
	}
	
	func didReceiveMicrophoneStatusAuthorized() {
		DispatchQueue.main.async { [view] in
			view?.showMicrophoneAuthorized()
		}
	}
	
	func didReceiveMicrophoneStatusDenied() {
		DispatchQueue.main.async { [view] in
			view?.showMicrophoneDenied()
		}
	}
	
	func didSendPushNotificationAboutNewCallToOpponent(_ opponent: SVUser) {
		
	}
	
	func didOpenDataChannel() {
		
	}
}
