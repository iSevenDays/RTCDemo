//
//  VideoCallStoryInteractorInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol VideoCallStoryInteractorInput {
	
	func startCallWithOpponent(_ opponent: SVUser)
	func acceptCallFromOpponent(_ opponent: SVUser)
	
	func hangup()
	
	/// Switch between back and front camera
	func switchCamera()
	
	/// Switch between speaker and headset
	func switchAudioRoute()
	
	/**
	Enable or disable sending local video track to the opponent
	
	didReceiveVideoStatusDenied will be called when video is not .authorized
	*/
	func switchLocalVideoTrackState()
	
	/**
	Enable or disable sending local audio track to the opponent
	
	didReceiveMicrophoneStatusDenied will be called when microphone is not .authorized
	*/
	func switchLocalAudioTrackState()
	
	
	/// Currently unused. For future use. The feature was working before feature/CallServiceRefactoring
	/// But currently there is no need
	func requestDataChannelState()
	func sendInvitationMessageAndOpenImageGallery()
	
    /**
	Request video permission status
	didReceiveVideoStatusAuthorized will be called if authorized
	didReceiveVideoStatusDenied will be called when .notDetermined or .denied
	*/
	func requestVideoPermissionStatus()
	
	/**
	Request microphone permission status
	didReceiveMicrophoneStatusAuthorized will be called if authorized
	didReceiveMicrophoneStatusDenied will be called when .notDetermined or .denied
	*/
	func requestMicrophonePermissionStatus()
}
