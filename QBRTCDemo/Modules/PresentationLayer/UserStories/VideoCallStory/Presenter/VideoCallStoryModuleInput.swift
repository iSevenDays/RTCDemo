//
//  VideoCallStoryModuleInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

protocol VideoCallStoryModuleInput: class {
	
	/**
	 @author Anton Sokolchenko
	
 	Configure module and start call with user
 	*/
	func connectToChatWithUser(user: SVUser, callOpponent: SVUser?)
	
	func acceptCallFromOpponent(opponent: SVUser)
}
