//
//  ChatUsersStoryInteractorOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum ChatUsersStoryInteractorError: ErrorType {
	case TagLengthMustBeGreaterThanThreeCharacters
	case CanNotRetrieveUsers
}

protocol ChatUsersStoryInteractorOutput: class {
	
	func didReceiveApprovedRequestForCallWithOpponent(opponent: SVUser)
	func didDeclineRequestForCallWithOpponent(opponent: SVUser, reason: String)
	
	func didRetrieveUsers(users: [SVUser])
	func didReceiveCallRequestFromOpponent(opponent: SVUser)
	
	func didError(error: ChatUsersStoryInteractorError)
	
	func didSetChatRoomName(chatRoomName: String)
	
	func didNotifyUsersAboutCurrentUserEnteredRoom()
	func didFailToNotifyUsersAboutCurrentUserEnteredRoom()
}
