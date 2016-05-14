//
//  ChatUsersStoryInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryInteractor: ChatUsersStoryInteractorInput {

    weak var output: ChatUsersStoryInteractorOutput!
	internal weak var restService: protocol<RESTServiceProtocol>!
	internal var cacheService: protocol<CacheServiceProtocol>!
	
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


protocol CacheServiceProtocol {
	func cacheUsers(users: [SVUser])
	func cachedUsers() -> [SVUser]?
}

extension NSUserDefaults: CacheServiceProtocol {
	func cacheUsers(users: [SVUser]) {
		let usersData = NSKeyedArchiver.archivedDataWithRootObject(users)
		setObject(usersData, forKey: "users")
	}
	
	func cachedUsers() -> [SVUser]? {
		guard let usersData = objectForKey("users") as? NSData else {
			NSLog("Warning: No stored users data")
			return nil
		}
		
		return NSKeyedUnarchiver.unarchiveObjectWithData(usersData) as? [SVUser]
	}
}