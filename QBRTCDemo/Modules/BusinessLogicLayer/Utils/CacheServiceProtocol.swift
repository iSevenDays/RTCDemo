//
//  CacheServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 21.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

@objc protocol CacheServiceProtocol: class {
	func cacheUsers(users: [SVUser])
	func cachedUsers() -> [SVUser]?
	func cachedUserWithID(id: Int) -> SVUser?
	
	func setBool(value: Bool, forKey defaultName: String)
	func boolForKey(defaultName: String) -> Bool
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
	
	func cachedUserWithID(id: Int) -> SVUser? {
		return self.cachedUsers()?.filter({$0.ID?.integerValue == id}).first
	}
}
