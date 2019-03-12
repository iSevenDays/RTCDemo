//
//  IncomingCallStoryInteractorInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol IncomingCallStoryInteractorInput {
	/**
	Set opponent, initiator of the call
	
	- parameter opponent: opponent, call initiator
	*/
	func setOpponent(_ opponent: SVUser)
	
	/**
	Retrieve opponent, call initiator
	
	- returns: SVUser instance
	*/
	func retrieveOpponent() -> SVUser
	
	/// Notifies opponent that current user rejected a call
	func rejectCall()
	
	/**
	Disable events handling, can be used to disable
	
	tracking hangup event and to disable closing IncomingCallStory
	When hangup is received (VideoCallStory is responsible when active)
	*/
	func stopHandlingEvents()
}
