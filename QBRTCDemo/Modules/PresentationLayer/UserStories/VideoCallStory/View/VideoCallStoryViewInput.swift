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
	func showStartDialingOpponent(_ opponent: SVUser)
	
	/// Show current user has accepted an offer for a call from the opponent
	func showCurrentUserAcceptedCallFromOpponent(_ opponent: SVUser)
	
	/// Show current user has received the answer from the opponent
	func showReceivedAnswerFromOpponent(_ opponent: SVUser)
	
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
	
	/// Data channel error not ready, currently not used
	func showErrorDataChannelNotReady()

	func configureLocalVideoViewWithBlock(_ block: ((RenderableView?) -> Void)?)

	func configureRemoteVideoViewWithBlock(_ block: ((RenderableView?) -> Void)?)
	
	/// Show local video track state (enabled/disabled)
	func showLocalVideoTrackEnabled(_ enabled: Bool)
	
	/// Show local audio track(microphone) state (enabled/disabled)
	func showLocalAudioTrackEnabled(_ enabled: Bool)
	
	/// Show the app can use camera
 	func showLocalVideoTrackAuthorized()
	
	/// Show the app is denied to use camera
	func showLocalVideoTrackDenied()
	
	/// Show the app can use microphone
	func showMicrophoneAuthorized()
	
	/// Show the app is denied to use microphone
	func showMicrophoneDenied()
	
	func showCameraPosition(_ backCamera: Bool)
}
