//
//  VideoCallStoryModuleInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

@objc protocol VideoCallStoryModuleInput: RamblerViperModuleInput {
	
	/**
	 @author Anton Sokolchenko
	
 	Configure module and start call with user
 	*/
	func startCallWithOpponent(_ opponent: SVUser)
	
	func acceptCallFromOpponent(_ opponent: SVUser)
}
