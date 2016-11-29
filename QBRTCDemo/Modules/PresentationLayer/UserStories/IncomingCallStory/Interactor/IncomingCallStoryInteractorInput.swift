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
	func setOpponent(opponent: SVUser)
	
	/**
	Retrieve opponent, call initiator
	
	- returns: SVUser instance
	*/
	func retrieveOpponent() -> SVUser
}
