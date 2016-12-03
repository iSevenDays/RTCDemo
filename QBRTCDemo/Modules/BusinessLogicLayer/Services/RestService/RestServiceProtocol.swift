//
//  RESTServiceProtocol.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 4/1/16.
//  Copyright © 2016 anton. All rights reserved.
//


protocol RESTServiceProtocol: class {
	
	/**
	Get current user if logged in REST
	
	- returns: SVUser instance or nil
	*/
	func currentUser() -> SVUser?
	
	func loginWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void)
	
	func signUpWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void)
	
	/**
	Update current user with requested user
	If currentUser properties are differ from
	requestUser properties, then current user should be be updated with requested user fields
	
	- parameter requestedUser: requested user to login with
	- parameter successBlock:  success block with SVUser instance
	- parameter errorBlock:    error block with error
	*/
	func updateCurrentUserFieldsIfNeededWithUser(requestedUser: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void)
	
	func downloadUsersWithTags(tags: [String], successBlock: (users: [SVUser]) -> Void, errorBlock: (error: NSError?) -> Void)
}
