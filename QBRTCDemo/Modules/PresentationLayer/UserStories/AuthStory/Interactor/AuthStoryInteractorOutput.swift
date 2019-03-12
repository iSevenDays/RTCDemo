//
//  AuthStoryInteractorOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol AuthStoryInteractorOutput: class {

	/**
	Notifies about doing login in with user
	note: can be called after doingLoginWithCachedUser
	*/
	func doingLoginWithUser(_ user: SVUser)
	
	/**
	Notifies about doing login with cached user
	*/
	func doingLoginWithCachedUser(_ user: SVUser)
	
	func doingSignUpWithUser(_ user: SVUser)
	
	func didLoginUser(_ user: SVUser)
	
	/**
	Called when user logined successfuly
	But returned user is nil (this should not happen)
	*/
	func didErrorLogin(_ error: Error?)
	
}
