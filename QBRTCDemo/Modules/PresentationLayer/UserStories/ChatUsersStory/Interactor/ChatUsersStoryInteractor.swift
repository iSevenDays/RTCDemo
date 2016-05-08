//
//  ChatUsersStoryInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 06/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class ChatUsersStoryInteractor: ChatUsersStoryInteractorInput {

    weak var output: ChatUsersStoryInteractorOutput!
	internal var restService: protocol<RESTServiceProtocol>!
	internal var cacheService: protocol<CacheServiceProtocol>!
	
	internal var tag: String?
	
	func retrieveUsersWithTag() {
		if let cachedUsers = cacheService.cachedUsers() {
			output.didRetrieveUsers(cachedUsers)
		}
		
		downloadUsersWithTag()
	}
	
	internal func downloadUsersWithTag() {
		guard let unwrappedTag = tag else {
			fatalError("Error tag does not set")
		}
		
		restService.downloadUsersWithTags([unwrappedTag], successBlock: { (users) in
			
			}) { (error) in
				
		}
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
			NSLog("Error: No stored users data")
			return nil
		}
		
		return NSKeyedUnarchiver.unarchiveObjectWithData(usersData) as? [SVUser]
	}
}