//
//  ChatUsersStoryInteractorInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol ChatUsersStoryInteractorInput {
	
 	/**
	Request a call with opponent
	
	didReceiveApprovedRequestForCall will be called if call can be made
	didDeclineRequestForCallWithUser: will be called if call can not be made
	- parameter opponent: SVUser instance
	*/
	func requestCallWithOpponent(opponent: SVUser)
	
	/**
	Retrieve users with tag
	
	didRetrieveUsers will be called if success
	didErrorRetrievingUsers if error
	*/
	func retrieveUsersWithTag()
	
	/**
	Sets tag (chat room name)
	
	- parameter tag: String instance, must be >= 3 characters long
	*/
	func setTag(tag: String, currentUser: SVUser)
	
	func retrieveCurrentUser() -> SVUser
}
