//
//  VideoCallStoryInteractorInput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol VideoCallStoryInteractorInput {

	/**
 	*  Connect to chat with user (if not connected before)
 	*  and then call an opponent (execute -startCallWithOpponent:)
 	*  if an opponent is nil, call will not happen
 	*
 	*  @param user SVUser instance
 	*  @param opponent SVUser instance
 	*/
	func connectToChatWithUser(user: SVUser, callOpponent opponent: SVUser?)
	
	func startCallWithOpponent(opponent: SVUser)
	func acceptCallFromOpponent(opponent: SVUser)
	
	func hangup()
	
	func requestDataChannelState()
	func sendInvitationMessageAndOpenImageGallery()
}
