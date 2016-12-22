//
//  VideoCallStoryInteractorInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol VideoCallStoryInteractorInput {
	
	func startCallWithOpponent(opponent: SVUser)
	func acceptCallFromOpponent(opponent: SVUser)
	
	func hangup()
	
	/// Switch between back and front camera
	func switchCamera()
	
	/// Switch between speaker and headset
	func switchAudioRoute()
	
	
	/// Currently unused. For future use. The feature was working before feature/CallServiceRefactoring
	/// But currently there is no need
	func requestDataChannelState()
	func sendInvitationMessageAndOpenImageGallery()
}
