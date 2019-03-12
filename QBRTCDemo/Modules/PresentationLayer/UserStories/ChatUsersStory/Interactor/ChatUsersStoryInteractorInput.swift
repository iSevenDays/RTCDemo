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
	func requestCallWithOpponent(_ opponent: SVUser)
	
	/**
	Retrieve users with tag
	
	didRetrieveUsers will be called if success
	didErrorRetrievingUsers if error
	*/
	func retrieveUsersWithTag()
	
	/**
	Sets chat room name
	
	- parameter chatRoomName: String instance, must be >= 3 characters long
	*/
	func setChatRoomName(_ chatRoomName: String)
	
	func retrieveCurrentUser() -> SVUser
	
 	/**
	Notify users in the chat room about current user entered the room,
	so they can immediately see new user
	*/
	func notifyUsersAboutCurrentUserEnteredRoom()
}
