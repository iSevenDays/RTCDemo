//
//  CacheServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 21.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

@objc protocol CacheServiceProtocol: class {
	func cacheUsers(users: [SVUser], forRoomName roomName: String)
	func cachedUsersForRoomWithName(roomName: String) -> [SVUser]?
	
	func setBool(value: Bool, forKey defaultName: String)
	func boolForKey(defaultName: String) -> Bool
	
	func setObject(value: AnyObject?, forKey defaultName: String)
	func stringForKey(defaultName: String) -> String?
}

extension NSUserDefaults: CacheServiceProtocol {
	
	func cacheUsers(users: [SVUser], forRoomName roomName: String) {
		let uniqueUsers = Array(Set(users))
		let usersData = NSKeyedArchiver.archivedDataWithRootObject(uniqueUsers)
		setObject(usersData, forKey: "users" + roomName)
		synchronize()
	}
	
	func cachedUsersForRoomWithName(roomName: String) -> [SVUser]? {
		guard let usersData = objectForKey("users" + roomName) as? NSData else {
			NSLog("%@", "Warning: No stored users data for room name \(roomName)")
			return nil
		}
		
		return NSKeyedUnarchiver.unarchiveObjectWithData(usersData) as? [SVUser]
	}
}
