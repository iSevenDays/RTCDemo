//
//  FakeQBService.swift
//  QBRTCDemo
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

class FakeQBRESTService : QBRESTService {
	
	var shouldLoginSuccessfully = true
	var shouldSignUpSuccessfully = true
	var shouldLoginAfterSignupSuccessfully = true
	
	var shouldDownloadUsersWithTags = true
	var usersWithTags: [SVUser] = [TestsStorage.svuserTest()]
	
	private var logined = false
	private var registered = false
	
	/**
	login user if shouldLoginSuccessfully OR registered && shouldLoginAfterSignupSuccessfully, then set 'logined' = true and call success block
	
	- parameter user:         SVUser insance
	- parameter successBlock: success block
	- parameter errorBlock:   error block
	*/
	override func loginWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		if shouldLoginSuccessfully ||
		(registered && shouldLoginAfterSignupSuccessfully) {
			logined = true
			successBlock?(user: user)
		} else {
			errorBlock?(nil)
		}
	}
	
	/**
	Sign up with user if shouldSignUpSuccessfully, then set 'registered' = true and call success block
	
	- parameter user:         SVUser insance
	- parameter successBlock: success block
	- parameter errorBlock:   error block
	*/
	override func signUpWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		if shouldSignUpSuccessfully {
			registered = true
			successBlock?(user: user)
		} else {
			errorBlock?(nil)
		}
	}
	
	/**
	Return array 'usersWithTags' if 'shouldDownloadUsersWithTags' is true
	
	- parameter tags:         argument has no effect
	- parameter successBlock: success block with users
	- parameter errorBlock:   error block
	*/
	override func downloadUsersWithTags(tags: [String], successBlock: ((users: [SVUser]) -> Void)?, errorBlock: ((error: NSError?) -> Void)?) {
		if shouldDownloadUsersWithTags {
			successBlock?(users: usersWithTags)
		} else {
			errorBlock?(error: nil)
		}
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