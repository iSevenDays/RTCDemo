//
//  ChatUsersStoryInteractorOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum ChatUsersStoryInteractorError: Error {
	case tagLengthMustBeGreaterThanThreeCharacters
	case canNotRetrieveUsers
}

protocol ChatUsersStoryInteractorOutput: class {
	
	func didReceiveApprovedRequestForCallWithOpponent(_ opponent: SVUser)
	func didDeclineRequestForCallWithOpponent(_ opponent: SVUser, reason: String)
	
	func didRetrieveUsers(_ users: [SVUser])
	func didReceiveCallRequestFromOpponent(_ opponent: SVUser)
	
	func didError(_ error: ChatUsersStoryInteractorError)
	
	func didSetChatRoomName(_ chatRoomName: String)
	
	func didNotifyUsersAboutCurrentUserEnteredRoom()
	func didFailToNotifyUsersAboutCurrentUserEnteredRoom()
}
