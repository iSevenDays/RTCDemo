//
//  VideoCallStoryViewInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol VideoCallStoryViewInput: class {

    /**
        @author Anton Sokolchenko
        Setup initial state of the view
    */
    func setupInitialState()
	
	/// Show current user is dialing the opponent
	func showStartDialingOpponent(opponent: SVUser)
	
	/// Show current user has received the answer from the opponent
	func showReceivedAnswerFromOpponent(opponent: SVUser)
	
	/// Show current user hang up a call
	func showHangup()
	
	/// Show an opponent hang up a call
	func showOpponentHangup()
	
	/// Show an opponent rejected a call
	func showOpponentReject()
	
	/// Show timeout occured calling the opponent
	func showOpponentAnswerTimeout()
	
	/// There might be a call at the moment, but call service was disconnected
	func showErrorCallServiceDisconnected()
	
	/// Failed to connect to chat
	func showErrorConnect()
	func showErrorDataChannelNotReady()
	func setLocalVideoCaptureSession(captureSession: AVCaptureSession)
	func configureRemoteVideoViewWithBlock(block: ((RTCEAGLVideoView?) -> Void)?)
}
