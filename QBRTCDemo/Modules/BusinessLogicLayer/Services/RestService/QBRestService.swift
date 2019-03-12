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
	case userLoginIsEmpty = 1
	case userPasswordIsNil = 2
	case userPasswordIsEmpty = 3
	case noTags = 4
}

/// Implements RESTServiceProtocol using QuickBlox API
class QBRESTService : RESTServiceProtocol {

	var isLoggedIn: Bool {
		return QBSession.current().currentUser != nil
	}
	
	/**
	Login in REST with user
	
	- parameter user:         SVUser instance
	- parameter successBlock: success block with retrieved user
	- parameter errorBlock:   error block
	*/
	func loginWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		guard !user.login.isEmpty else {
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.userLoginIsEmpty.rawValue, userInfo: nil))
			return
		}
		
		guard let userPassword = user.password else {
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.userPasswordIsNil.rawValue, userInfo: nil))
			return
		}
		
		guard !userPassword.isEmpty else {
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.userPasswordIsEmpty.rawValue, userInfo: nil))
			return
		}
		
		QBRequest.logIn(withUserLogin: user.login, password: userPassword, successBlock: { (response, user) in
			
			guard user != nil else {
				errorBlock(response.error?.error)
				return
			}
			
			let svUser = SVUser(qbuUser: user)
			svUser?.password = user?.password
			
			successBlock(svUser!)
			
		}) { (response) in
			errorBlock(response.error?.error)
		}
	}
	
	func signUpWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		
		guard !user.login.isEmpty else {
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.userLoginIsEmpty.rawValue, userInfo: nil))
			return
		}
		
		guard let userPassword = user.password else {
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.userPasswordIsNil.rawValue, userInfo: nil))
			return
		}
		
		guard !userPassword.isEmpty else {
			print("user password must not be empty")
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.userPasswordIsEmpty.rawValue, userInfo: nil))
			return
		}
		let qbUser = QBUUser(svUser: user)
		QBRequest.signUp(qbUser, successBlock: { (response, restUser) in
			
			guard restUser != nil else {
				errorBlock(response.error?.error)
				return
			}
			
			let svUser = SVUser(qbuUser: restUser)
			svUser?.password = qbUser.password
			
			successBlock(svUser!)
			
			
		}) { (response) in
			errorBlock(response.error?.error)
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
	func updateCurrentUserFieldsIfNeededWithUser(_ requestedUser: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		
		guard let qbCurrentUser = QBSession.current().currentUser else {
			NSLog("Error can not update user without being logged in")
			errorBlock(nil)
			return
		}
		
		guard requestedUser.password != nil else {
			NSLog("Error requestedUser must have a password set")
			errorBlock(nil)
			return
		}
		
		let qbTags = qbCurrentUser.tags ?? []
		let svTags = NSMutableArray(array:  requestedUser.tags!)
		
		if qbCurrentUser.fullName == requestedUser.fullName &&
			qbTags.isEqual(to: svTags as [AnyObject]) {
			NSLog("QB User is equal SV User, don't need to update")
			successBlock(requestedUser)
			return
		}
		
		let params = QBUpdateUserParameters()
		params.fullName = requestedUser.fullName
		params.tags = NSMutableArray(array: requestedUser.tags!)
		
		QBRequest.updateCurrentUser(params, successBlock: { (response, qbuser) in
			
			let svUser = SVUser(qbuUser: qbuser)
			svUser?.password = requestedUser.password
			successBlock(svUser!)
			
		}) { (response) in
			errorBlock(response.error?.error as NSError?)
		}
	}
	
	func downloadUsersWithTags(_ tags: [String], successBlock: @escaping (_ users: [SVUser]) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		
		guard tags.count > 0 else {
			errorBlock(NSError(domain: QBRESTServiceErrorDomain, code: QBRESTServiceErrorCode.noTags.rawValue, userInfo: nil))
			return
		}
		let page = QBGeneralResponsePage(currentPage: 1, perPage: 100)
		QBRequest.users(withTags: tags, page: page, successBlock: { (response, page, users) in
			guard let unwrappedUsers = users else {
				errorBlock(response.error?.error)
				return
			}

			var svUsers: [SVUser] = []

			for qbUser in unwrappedUsers {
				let svUser = SVUser(qbuUser: qbUser)
				svUsers.append(svUser!)
			}

			successBlock(svUsers)
		}) { (response) in
			errorBlock(response.error?.error)
		}
		
	}
	
	
	
}
