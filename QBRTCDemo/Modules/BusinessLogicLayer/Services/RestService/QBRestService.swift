//
//  QBRESTService.swift
//  RTCDemo
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
	
	func currentUser() -> SVUser? {
		if let qbuser = QBSession.currentSession().currentUser {
			return SVUser.init(QBUUser: qbuser)
		}
		
		return nil
	}
	
	/**
	Login in REST with user
	
	- parameter user:         SVUser instance
	- parameter successBlock: success block with retrieved user
	- parameter errorBlock:   error block
	*/
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
			errorBlock(error: NSError.init(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.UserPasswordIsEmpty.rawValue, userInfo: nil))
			return
		}
		let qbUser = QBUUser(SVUser: user)
		QBRequest.signUp(qbUser, successBlock: { (response, restUser) in
			
			guard restUser != nil else {
				errorBlock(error: response.error?.error)
				return
			}
			
			let svUser = SVUser(QBUUser: restUser)
			svUser.password = qbUser.password
			
			successBlock(user: svUser)
			
			
			}) { (response) in
				errorBlock(error: response.error?.error)
		}
		
	}
	
	/**
	Update current user with requested user
	If QBSession.currentSession().currentUser properties fullname and tags are differ from
	requestUser properties, then current QB user will be updated with requested user fields
	
	- parameter requestedUser: requested user to login with
	- parameter successBlock:  success block with SVUser instance
	- parameter errorBlock:    error block with error
	*/
	func updateCurrentUserFieldsIfNeededWithUser(requestedUser: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void) {
		
		guard let qbCurrentUser = QBSession.currentSession().currentUser else {
			NSLog("Error can not update user without being logged in")
			errorBlock(error: nil)
			return
		}
		
		let qbTags = qbCurrentUser.tags ?? []
		let svTags = NSMutableArray(array:  requestedUser.tags!)
		
		if qbCurrentUser.fullName == requestedUser.fullName &&
			qbTags.isEqualToArray(svTags as [AnyObject]) {
				NSLog("QB User is equal SV User, don't need to update")
				successBlock(user: requestedUser)
				return
		}
		
		
		let params = QBUpdateUserParameters.init()
		params.fullName = requestedUser.fullName
		params.tags = NSMutableArray(array: requestedUser.tags!)
		
		QBRequest.updateCurrentUser(params, successBlock: { (response, qbuser) in
			
			let svUser = SVUser.init(QBUUser: qbuser)
			
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
		let page = QBGeneralResponsePage(currentPage: 1, perPage: 100)
		
		QBRequest.usersWithTags(tags, page: page, successBlock: { (response, page, users) in
			
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
