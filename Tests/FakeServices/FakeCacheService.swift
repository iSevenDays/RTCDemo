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

	func set(_ value: Bool, forKey defaultName: String) {
		
	}

	func set(_ value: Any?, forKey defaultName: String) {

	}

	func string(forKey: String) -> String? {
		return nil
	}

	func bool(forKey: String) -> Bool {
		return true
	}
	
	func cachedUserWithID(_ id: Int) -> SVUser? {
		return nil
	}
}

extension FakeCacheService: CacheServiceChatRoomProtocol {
	func cacheUsers(_ users: [SVUser], forRoomName roomName: String) {
		cachedUsersArray = users
	}

	func cachedUsersForRoomWithName(_ roomName: String) -> [SVUser]? {
		return cachedUsersArray
	}
}
