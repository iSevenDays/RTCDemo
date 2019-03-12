//
//  VideoCallStoryInteractorOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import CoreFoundation
typealias RenderableView = (UIView & RTCVideoRenderer)

@objc protocol VideoCallStoryInteractorOutput: class {
	/// Current user called hangup
	func didHangup()
	
	/// Method is called when hangup is received from opponent user in a current call
	func didReceiveHangupFromOpponent(_ opponent: SVUser)
	
	/// Method is called when reject for a call is received from opponent user
	func didReceiveRejectFromOpponent(_ opponent: SVUser)
	
	/// Method is called when answer timeout occured for calling the given opponent
	func didReceiveAnswerTimeoutForOpponent(_ opponent: SVUser)
	
	func didFailToConnectToChat()
	func didReceiveLocalVideoTrackWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?)
	func didReceiveRemoteVideoTrackWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?)
	func willSwitchDevicePositionWithConfigurationBlock(_ block: ((_ renderer: RenderableView?) -> Void)?)
	func didOpenDataChannel()
	func didReceiveDataChannelStateReady()
	func didReceiveDataChannelStateNotReady()
	
	/// Sender has sent us(receiver side) invitation to open image gallery and start sync
	func didReceiveInvitationToOpenImageGallery()
	
	/// We have sent to a receiver an invitation to open image gallery and start sync
	func didSendInvitationToOpenImageGallery()
	
	/**
	 * Call service was interrupted due to errors in signaling channel
	 * a call must be closed
	 */
	func didFailCallService()
	
	func didStartDialingOpponent(_ opponent: SVUser)
	func didReceiveAnswerFromOpponent(_ opponent: SVUser)
	
	func didSendPushNotificationAboutNewCallToOpponent(_ opponent: SVUser)
	
	func didSwitchCameraPosition(_ backCamera: Bool)
	
	/// Called when local video track state is changed
	func didSwitchLocalVideoTrackState(_ enabled: Bool)
	
	/// Called when local audio track state is changed
	func didSwitchLocalAudioTrackState(_ enabled: Bool)
	
	/// Called when the app is authorized to use camera
	func didReceiveVideoStatusAuthorized()
	
	/// Called when the app is denied to use camera
	func didReceiveVideoStatusDenied()
	
	/// Called when the app is authorized to use microphone
	func didReceiveMicrophoneStatusAuthorized()
	
	/// Called when the app is denied to use microphone
	func didReceiveMicrophoneStatusDenied()
}
