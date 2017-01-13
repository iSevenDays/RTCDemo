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
	internal weak var cacheService: CacheServiceProtocol!
	internal weak var callService: CallServiceProtocol!
	
	internal var chatRoomName: String?
	internal var currentUser: SVUser!
	
	/**
	Sets tag (chat room name)
	
	- parameter tag: String instance, must be >= 3 characters long
	- parameter currentUser: current user
	*/
	func setChatRoomName(chatRoomName: String) {
		guard chatRoomName.characters.count >= 3 else {
			
			self.output?.didError(ChatUsersStoryInteractorError.TagLengthMustBeGreaterThanThreeCharacters)
			return
			
		}
		
		self.chatRoomName = chatRoomName
	}
	
	func retrieveCurrentUser() -> SVUser {
		return callService.currentUser!
	}
	
	/**
	Retrieves users from cache, then downloads them from REST
 
	Step 1 download users from cache and notify output
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
	
	func requestCallWithOpponent(opponent: SVUser) {
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
	
	/**
	Download user with tag and cache
	*/
	internal func downloadUsersWithTag() {
		guard let unwrappedTag = chatRoomName else {
			fatalError("Error tag has not been set")
		}
		
		restService.downloadUsersWithTags([unwrappedTag], successBlock: { [unowned self] (users) in
			
			let filteredUsers = self.removeCurrentUserFromUsers(users)
			
			self.output?.didRetrieveUsers(filteredUsers)
			
			self.cacheService.cacheUsers(filteredUsers, forRoomName: unwrappedTag)
			
			}) { (error) in
				self.output?.didError(ChatUsersStoryInteractorError.CanNotRetrieveUsers)
		}
	}
	
	internal func removeCurrentUserFromUsers(users: [SVUser]) -> [SVUser] {
		guard let currentUserID = callService.currentUser?.ID else {
			NSLog("Current user is not presented in users array")
			return users
		}
		
		return users.filter({$0.ID?.isEqualToNumber(currentUserID) == false})
	}
}

extension ChatUsersStoryInteractor: CallServiceObserver {
	func callService(callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
		output?.didReceiveCallRequestFromOpponent(opponent)
	}
}
