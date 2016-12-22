//
//  ChatUsersStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryInteractor: NSObject, ChatUsersStoryInteractorInput {

    weak var output: ChatUsersStoryInteractorOutput!
	internal weak var restService: RESTServiceProtocol!
	internal weak var cacheService: CacheServiceProtocol!
	
	internal var tag: String?
	internal var currentUser: SVUser!
	
	/**
	Sets tag (chat room name)
	
	- parameter tag: String instance, must be >= 3 characters long
	- parameter currentUser: current user
	*/
	func setTag(tag: String, currentUser: SVUser) {
		guard tag.characters.count >= 3 else {
			
			self.output.didError(ChatUsersStoryInteractorError.TagLengthMustBeGreaterThanThreeCharacters)
			return
			
		}
		
		self.tag = tag
		self.currentUser = currentUser
	}
	
	func retrieveCurrentUser() -> SVUser {
		return currentUser
	}
	
	/**
	Retrieves users from cache, then downloads them from REST
 
	Step 1 download users from cache and notify output
	Step 2 download users from REST and notify output
	
	*/
	func retrieveUsersWithTag() {
		if let cachedUsers = cacheService.cachedUsers() {
			output.didRetrieveUsers(cachedUsers)
		}
		
		downloadUsersWithTag()
	}
	
	/**
	Download user with tag and cache
	*/
	internal func downloadUsersWithTag() {
		guard let unwrappedTag = tag else {
			fatalError("Error tag has not been set")
		}
		
		restService.downloadUsersWithTags([unwrappedTag], successBlock: { [unowned self] (users) in
			
			let filteredUsers = self.removeCurrentUserFromUsers(users)
			
			self.output.didRetrieveUsers(filteredUsers)
			
			self.cacheService.cacheUsers(filteredUsers)
			
			}) { (error) in
				self.output.didError(ChatUsersStoryInteractorError.CanNotRetrieveUsers)
		}
	}
	
	internal func removeCurrentUserFromUsers(users: [SVUser]) -> [SVUser] {
		guard let currentUserID = restService.currentUser()?.ID else {
			NSLog("Current user is not presented in users array")
			return users
		}
		
		return users.filter({$0.ID!.isEqualToNumber(currentUserID) == false})
	}
}

extension ChatUsersStoryInteractor: CallServiceObserver {
	func callService(callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
		output.didReceiveCallRequestFromOpponent(opponent)
	}
}
