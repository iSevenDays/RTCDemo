//
//  ChatUsersStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryInteractor: ChatUsersStoryInteractorInput {

    weak var output: ChatUsersStoryInteractorOutput?
	internal weak var restService: RESTServiceProtocol!
	internal weak var cacheService: CacheServiceChatRoomProtocol!
	internal weak var callService: (CallServiceProtocol & CallServiceChatRoomProtocol)!
	
	internal var chatRoomName: String?
	internal var currentUser: SVUser!
	
	// Already notified users about current user entered to the given chat room name
	// Chat room name: Users
	internal var notifiedUsers: [String: [SVUser]] = [:]
	
	/**
	Sets chat room name
	
	- parameter chatRoomName: String instance, must be >= 3 characters long
	*/
	func setChatRoomName(_ chatRoomName: String) {
		guard chatRoomName.count >= 3 else {
			self.output?.didError(ChatUsersStoryInteractorError.tagLengthMustBeGreaterThanThreeCharacters)
			return
		}
		
		self.chatRoomName = chatRoomName
		
		output?.didSetChatRoomName(chatRoomName)
	}
	
	func retrieveCurrentUser() -> SVUser {
		return callService.currentUser!
	}
	
	/**
	Retrieves users from cache, then downloads them from REST
 
	Step 1 get users from cache and notify output
	Step 2 download users from REST and notify output
	
	*/
	func retrieveUsersWithTag() {
		guard let unwrappedTag = chatRoomName else {
			NSLog("%@", "Error: tag is not set")
			return
		}
		
		if let cachedUsers = cacheService.cachedUsersForRoomWithName(unwrappedTag) {
			output?.didRetrieveUsers(cachedUsers)
		}
		
		downloadUsersWithTag()
	}
	
	/**
	Download user with tag(chat room name) and cache
	*/
	internal func downloadUsersWithTag() {
		guard let unwrappedTag = chatRoomName else {
			fatalError("Error tag has not been set")
		}
		
		restService.downloadUsersWithTags([unwrappedTag], successBlock: { [unowned self] (users) in
			
			let filteredUsers = self.removeCurrentUserFromUsers(users)
			
			self.cacheService.cacheUsers(filteredUsers, forRoomName: unwrappedTag)
			
			self.output?.didRetrieveUsers(filteredUsers)
			}) { (error) in
				self.output?.didError(ChatUsersStoryInteractorError.canNotRetrieveUsers)
		}
	}
	
	func requestCallWithOpponent(_ opponent: SVUser) {
		if callService.isConnected {
			output?.didReceiveApprovedRequestForCallWithOpponent(opponent)
		} else {
			var message = "No internet connection. Please check your settings and try again later"
			
			if callService.isConnecting {
				message = "Reconnecting...\nPlease try again"
			}
			
			output?.didDeclineRequestForCallWithOpponent(opponent, reason: message)
		}
	}
	
	func notifyUsersAboutCurrentUserEnteredRoom() {
		guard let chatRoomName = self.chatRoomName else {
			output?.didFailToNotifyUsersAboutCurrentUserEnteredRoom()
			return
		}
		
		guard let usersInChatRoom = cacheService.cachedUsersForRoomWithName(chatRoomName) else {
			output?.didFailToNotifyUsersAboutCurrentUserEnteredRoom()
			return
		}
		
		for user in usersInChatRoom {
			if var notifiedCurrentChatRoomUsers = notifiedUsers[chatRoomName] {
				guard !notifiedCurrentChatRoomUsers.contains(user) else { return }
				notifiedCurrentChatRoomUsers.append(user)
				notifiedUsers[chatRoomName] = notifiedCurrentChatRoomUsers
			} else {
				notifiedUsers[chatRoomName] = [user]
			}
			callService.sendMessageCurrentUserEnteredChatRoom(chatRoomName, toUser: user)
			
		}
		
		output?.didNotifyUsersAboutCurrentUserEnteredRoom()
	}
	
	internal func removeCurrentUserFromUsers(_ users: [SVUser]) -> [SVUser] {
		guard let currentUserID = callService.currentUser?.id else {
			NSLog("Current user is not presented in users array")
			return users
		}
		return users.filter({$0.id?.isEqual(to: currentUserID) == false})
	}
}

extension ChatUsersStoryInteractor: CallServiceObserver {
	func callService(_ callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
		output?.didReceiveCallRequestFromOpponent(opponent)
	}
	
	func callService(_ callService: CallServiceProtocol, didReceiveUser user: SVUser, forChatRoomName chatRoomName: String) {
		var usersForChatRoomName: [SVUser] = []
		var shouldReloadTable = false
		
		if var cachedUsers = cacheService.cachedUsersForRoomWithName(chatRoomName) {
			if !cachedUsers.contains(user) {
				cachedUsers.append(user)
				shouldReloadTable = true
			}
			usersForChatRoomName = cachedUsers
			cacheService.cacheUsers(cachedUsers, forRoomName: chatRoomName)
		} else {
			shouldReloadTable = true
			usersForChatRoomName = [user]
			cacheService.cacheUsers(usersForChatRoomName, forRoomName: chatRoomName)
		}
		
		if self.chatRoomName == chatRoomName {
			if shouldReloadTable {
				output?.didRetrieveUsers(usersForChatRoomName)
			}
		}
	}
}
