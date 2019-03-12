//
//  RESTServiceProtocol.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 4/1/16.
//  Copyright © 2016 anton. All rights reserved.
//


protocol RESTServiceProtocol: class {
	
	var isLoggedIn: Bool { get }
	
	func loginWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void)
	
	func signUpWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void)
	
	/**
	Update current user with requested user
	If currentUser properties are differ from
	requestUser properties, then current user should be be updated with requested user fields
	
	- parameter requestedUser: requested user to login with
	- parameter successBlock:  success block with SVUser instance
	- parameter errorBlock:    error block with error
	*/
	func updateCurrentUserFieldsIfNeededWithUser(_ requestedUser: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void)
	
	func downloadUsersWithTags(_ tags: [String], successBlock: @escaping (_ users: [SVUser]) -> Void, errorBlock: @escaping (_ error: Error?) -> Void)
}
