//
//  QBRESTService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 4/1/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

let QBRESTServiceErrorDomain = "QBRESTServiceErrorDomain"

enum QBRESTServiceErrorCode: Int {
	case UserLoginIsEmpty = 1
	case UserPasswordIsNil = 2
	case UserPasswordIsEmpty = 3
	case NoTags = 4
}

/// Implements RESTServiceProtocol using QuickBlox API
class QBRESTService : RESTServiceProtocol {
	
	func loginWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void) {
		guard !user.login.isEmpty else {
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.UserLoginIsEmpty.rawValue, userInfo: nil))
			return
		}
		
		guard let userPassword = user.password else {
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.UserPasswordIsNil.rawValue, userInfo: nil))
			return
		}
		
		guard !userPassword.isEmpty else {
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.UserPasswordIsEmpty.rawValue, userInfo: nil))
			return
		}
		
		QBRequest.logInWithUserLogin(user.login, password: userPassword, successBlock: { (response, user) in
			
			guard user != nil else {
				errorBlock(error: response.error?.error)
				return
			}
			
			let svUser = SVUser.init(QBUUser: user)
			svUser.password = user?.password
			
			successBlock(user: svUser)
			
			}) { (response) in
				errorBlock(error: response.error?.error)
		}
	}
	
	func signUpWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void) {
		
		guard !user.login.isEmpty else {
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.UserLoginIsEmpty.rawValue, userInfo: nil))
			return
		}
		
		guard let userPassword = user.password else {
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.UserPasswordIsNil.rawValue, userInfo: nil))
			return
		}
		
		guard !userPassword.isEmpty else {
			print("user password must not be empty")
			return
		}
		
		QBRequest.signUp(QBUUser.init(SVUser: user), successBlock: { (response, user) in
			
			guard user != nil else {
				errorBlock(error: response.error?.error)
				return
			}
			
			let svUser = SVUser.init(QBUUser: user)
			svUser.password = user?.password
			
			successBlock(user: svUser)
			
			
			}) { (response) in
				errorBlock(error: response.error?.error)
		}
		
	}
	
	func downloadUsersWithTags(tags: [String], successBlock: (users: [SVUser]) -> Void, errorBlock: (error: NSError?) -> Void) {
		
		guard tags.count > 0 else {
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.NoTags.rawValue, userInfo: nil))
			return
		}
		
		QBRequest.usersWithTags(tags, successBlock: { (response, page, users) in
			
			guard let unwrappedUsers = users else {
				errorBlock(error: response.error?.error)
				return
			}
			
			var svUsers: [SVUser] = []
			
			for qbUser in unwrappedUsers {
				let svUser = SVUser.init(QBUUser: qbUser)
				svUsers.append(svUser)
			}
			
			successBlock(users: svUsers)
			
			}) { (response) in
				errorBlock(error: response.error?.error)
		}
		
	}
	
	
	
}