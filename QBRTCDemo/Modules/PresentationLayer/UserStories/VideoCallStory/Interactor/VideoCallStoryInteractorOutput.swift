//
//  VideoCallStoryInteractorOutput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

@objc protocol VideoCallStoryInteractorOutput: class {
	func didConnectToChatWithUser(user: SVUser)
	
	// Current user called hangup
	func didHangup()
	
	// Method is called when hangup is received from opponent user in a current call
	func didReceiveHangupFromOpponent(opponent: SVUser)
	
	func didFailToConnectToChat()
	func didSetLocalCaptureSession(localCaptureSession: AVCaptureSession)
	func didReceiveRemoteVideoTrackWithConfigurationBlock(block: ((renderer: RTCEAGLVideoView?) -> Void)?)
	func didOpenDataChannel()
	func didReceiveDataChannelStateReady()
	func didReceiveDataChannelStateNotReady()
	
	/// Sender has sent us(receiver side) invitation to open image gallery and start sync
	func didReceiveInvitationToOpenImageGallery()
	
	/// We have sent to a receiver an invitation to open image gallery and start sync
	func didSendInvitationToOpenImageGallery()
}
