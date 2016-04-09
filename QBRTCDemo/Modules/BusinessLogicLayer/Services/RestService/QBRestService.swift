//
//  QBRESTService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 4/1/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

/// Implements RESTServiceProtocol using QuickBlox API
class QBRESTService : RESTServiceProtocol {
	
	func loginWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		guard !user.login.isEmpty else {
			print("user login must not be empty")
			return
		}
		
		guard let userPassword = user.password else {
			print("user password is nil")
			return
		}
		
		guard !userPassword.isEmpty else {
			print("user password must not be empty")
			return
		}
		
		QBRequest.logInWithUserLogin(user.login, password: userPassword, successBlock: { (response, user) in
			
			guard user != nil else {
				errorBlock?(response.error?.error)
				return
			}
			
			let svUser = SVUser.init(QBUUser: user)
			svUser.password = user?.password
			
			successBlock?(user: svUser)
			
			}) { (response) in
				errorBlock?(response.error?.error)
		}
	}
	
	func signUpWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		
		guard !user.login.isEmpty else {
			print("user login must not be empty")
			return
		}
		
		guard let userPassword = user.password else {
			print("user password is nil")
			return
		}
		
		guard !userPassword.isEmpty else {
			print("user password must not be empty")
			return
		}
		
		QBRequest.signUp(QBUUser.init(SVUser: user), successBlock: { (response, user) in
			
			guard user != nil else {
				errorBlock?(response.error?.error)
				return
			}
			
			let svUser = SVUser.init(QBUUser: user)
			svUser.password = user?.password
			
			successBlock?(user: svUser)
			
			
			}) { (response) in
				errorBlock?(response.error?.error)
		}
		
	}
	
}