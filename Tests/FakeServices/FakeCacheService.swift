//
//  FakeCacheService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 16.01.17.
//  Copyright © 2017 Anton Sokolchenko. All rights reserved.
//

import Foundation

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class FakeCacheService: NSObject, CacheServiceProtocol {
	var cachedUsersArray: [SVUser]? = [TestsStorage.svuserTest]
	
	func setBool(value: Bool, forKey defaultName: String) {
		
	}
	
	func boolForKey(defaultName: String) -> Bool {
		return true
	}
	
	func cachedUserWithID(id: Int) -> SVUser? {
		return nil
	}
	
	func cacheUsers(users: [SVUser], forRoomName roomName: String) {
		cachedUsersArray = users
	}
	
	func cachedUsersForRoomWithName(roomName: String) -> [SVUser]? {
		return cachedUsersArray
	}
}
