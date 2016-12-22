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
}

extension NSUserDefaults: CacheServiceProtocol {
	
	func cacheUsers(users: [SVUser], forRoomName roomName: String) {
		let usersData = NSKeyedArchiver.archivedDataWithRootObject(users)
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
