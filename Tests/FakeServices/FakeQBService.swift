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
	
	private var logined = false
	private var registered = false
	
	override func loginWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		if shouldLoginSuccessfully ||
		(registered && shouldLoginAfterSignupSuccessfully) {
			logined = true
			successBlock?(user: user)
		} else {
			errorBlock?(nil)
		}
	}
	
	override func signUpWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		if shouldSignUpSuccessfully {
			registered = true
			successBlock?(user: user)
		} else {
			errorBlock?(nil)
		}
	}
	
	func tearDown() {
		shouldLoginSuccessfully = true
		shouldSignUpSuccessfully = true
		shouldLoginAfterSignupSuccessfully = true
		logined = false
		registered = false
	}
	
}