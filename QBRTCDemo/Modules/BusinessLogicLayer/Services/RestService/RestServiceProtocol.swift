//
//  RESTServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 4/1/16.
//  Copyright © 2016 anton. All rights reserved.
//


protocol RESTServiceProtocol {
	
	func loginWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void)
	
	func signUpWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void)
	
	func downloadUsersWithTags(tags: [String], successBlock: (users: [SVUser]) -> Void, errorBlock: (error: NSError?) -> Void)
}
