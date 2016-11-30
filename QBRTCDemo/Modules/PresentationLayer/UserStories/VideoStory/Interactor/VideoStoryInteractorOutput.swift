//
//  VideoStoryInteractorOutput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 30.11.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

@objc protocol VideoStoryInteractorOutput: NSObjectProtocol {
	func didConnectToChatWithUser(user: SVUser)
	func didHangup()
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
