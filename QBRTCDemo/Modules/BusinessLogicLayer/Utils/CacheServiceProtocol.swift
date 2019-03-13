//
//  CacheServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 21.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol CacheServiceChatRoomProtocol: class {
	func cacheUsers(_ users: [SVUser], forRoomName roomName: String)
	func cachedUsersForRoomWithName(_ roomName: String) -> [SVUser]?
}

protocol CacheServiceProtocol: class {
	func set(_ value: Bool, forKey defaultName: String)
	func bool(forKey defaultName: String) -> Bool
	
	func set(_ value: Any?, forKey defaultName: String)
	func string(forKey defaultName: String) -> String?
}


extension UserDefaults: CacheServiceProtocol {
}
extension UserDefaults: CacheServiceChatRoomProtocol {
	
	func cacheUsers(_ users: [SVUser], forRoomName roomName: String) {
		let uniqueUsers = Array(Set(users))
		let usersData = NSKeyedArchiver.archivedData(withRootObject: uniqueUsers)
		set(usersData, forKey: "users" + roomName)
		synchronize()
	}

	
	func cachedUsersForRoomWithName(_ roomName: String) -> [SVUser]? {
		guard let usersData = object(forKey: "users" + roomName) as? Data else {
			NSLog("%@", "Warning: No stored users data for room name \(roomName)")
			return nil
		}
		
		return NSKeyedUnarchiver.unarchiveObject(with: usersData) as? [SVUser]
	}
}
