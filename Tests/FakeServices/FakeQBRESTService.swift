//
//  FakeQBRESTService.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 4/2/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif
import Quickblox

class FakeQBRESTService : QBRESTService {
	
	var shouldLoginSuccessfully = true
	var shouldSignUpSuccessfully = true
	var shouldLoginAfterSignupSuccessfully = true
	
	var shouldDownloadUsersWithTags = true
	var usersWithTags: [SVUser] = [TestsStorage.svuserTest]
	
	fileprivate var logined = false
	fileprivate var registered = false
	
	internal var updatedUser: SVUser?
	
	override init() {
		QBSettings.setApplicationID(31016)
		QBSettings.setAuthKey("aqsHa2AhDO5Z9Th")
		QBSettings.setAuthSecret("825Bv-3ByACjD4O")
		QBSettings.setAccountKey("ZsFuaKozyNC3yLzvN3Xa")
	}
	
	/**
	login user if shouldLoginSuccessfully OR registered && shouldLoginAfterSignupSuccessfully, then set 'logined' = true and call success block
	
	- parameter user:         SVUser insance
	- parameter successBlock: success block
	- parameter errorBlock:   error block
	*/
	override func loginWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		if shouldLoginSuccessfully ||
		(registered && shouldLoginAfterSignupSuccessfully) {
			logined = true
			user.ID = 777
			successBlock(user)
		} else {
			errorBlock(nil)
		}
	}
	
	/**
	Sign up with user if shouldSignUpSuccessfully, then set 'registered' = true and call success block
	
	- parameter user:         SVUser insance
	- parameter successBlock: success block
	- parameter errorBlock:   error block
	*/
	override func signUpWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		if shouldSignUpSuccessfully {
			registered = true
			user.ID = 888
			successBlock(user)
		} else {
			errorBlock(nil)
		}
	}
	
	/**
	Return array 'usersWithTags' if 'shouldDownloadUsersWithTags' is true
	
	- parameter tags:         argument has no effect
	- parameter successBlock: success block with users
	- parameter errorBlock:   error block
	*/
	override func downloadUsersWithTags(_ tags: [String], successBlock: @escaping (_ users: [SVUser]) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		if shouldDownloadUsersWithTags {
			successBlock(usersWithTags)
		} else {
			errorBlock(nil)
		}
	}
	
	override func updateCurrentUserFieldsIfNeededWithUser(_ requestedUser: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		successBlock(requestedUser)
	}
	
	func tearDown() {
		shouldLoginSuccessfully = true
		shouldSignUpSuccessfully = true
		shouldLoginAfterSignupSuccessfully = true
		shouldDownloadUsersWithTags = true
		logined = false
		registered = false
	}
	
}
