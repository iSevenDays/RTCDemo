//
//  AuthStoryInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import AdSupport // for UDID

class AuthStoryInteractor: AuthStoryInteractorInput {

    weak var output: AuthStoryInteractorOutput!
	internal weak var restService: protocol<RESTServiceProtocol>!
	internal weak var callService: protocol<CallServiceProtocol>!
	
	// MARK: AuthStoryInteractorInput
	func tryRetrieveCachedUser() {
		if let cachedUser = cachedUser() {
			guard let userTags = cachedUser.tags else {
				print("error: cached user has not tags")
				return
			}
			output.doingLoginWithCachedUser(cachedUser)
			signUpOrLoginWithUserName(cachedUser.fullName, tags: userTags)
		}
	}
	
	func signUpOrLoginWithUserName(userName: String, tags: [String]) {
		
		let login = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
		let password = "zZc64fj13$_1=fx%"
		
		let user = SVUser.init(ID: nil, login: login, password: password, tags: tags)
		user.fullName = userName
		
		signUpOrLoginWithUserInRESTSimulatenouslyWithChat(user, successBlock: { [weak self] (user) in
			
			user.password = password
			self?.cacheUser(user)
			self?.output.didLoginUser(user)
			
			}) { [weak self] (error) in
				
				self?.output.didErrorLogin(error)
		}
	}
	
	/**
	Sign up or login in REST and connect to chat at the same time to speed up connection
	
	- parameter user:         SVUser instance
	- parameter successBlock: successBlock with SVUser instance
	- parameter errorBlock:   error block
	*/
	func signUpOrLoginWithUserInRESTSimulatenouslyWithChat(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (error: NSError?) -> Void) {
		
		assert(user.password != nil)
		
		var loggedInREST = false
		var connectedToChat = false
		
		signUpOrLoginWithUser(user, successBlock: {(restUser) in
			
			loggedInREST = true
			
			if self.callService.isConnected {
				successBlock(user: user)
				return
			}
			
			self.callService.connectWithUser(user, completion: { (error) in
				if error != nil || !self.callService.isConnected {
					errorBlock(error: error)
					return
				}
				
				connectedToChat = true
				
				assert(loggedInREST)
				assert(connectedToChat)
				
				successBlock(user: user)
			})
			
		}) { (error) in
			
			errorBlock(error: error)
		}
		
		callService.connectWithUser(user) { (error) in
			if self.callService.isConnected {
				connectedToChat = true
			}
			
			if loggedInREST && connectedToChat {
				successBlock(user: user)
			}
		}
		
	}
}


// MARK: - Internal
internal extension AuthStoryInteractor {
	/**
	Signup or login with user
	
	1. Notify presenter about login
	2. Login
	3. Login was successful    -> successBlock
	4. Login was unsuccessful  -> notify presenter about signup
	5. Signup was successful   -> successBlock
	5. Signup was unsuccessful -> error block
	
	- parameter user:         SVUser instance
	- parameter successBlock: success block
	- parameter errorBlock:   error block
	*/
	func signUpOrLoginWithUser(user: SVUser, successBlock: (user: SVUser) -> Void, errorBlock: (NSError?) -> Void) {
		output.doingLoginWithUser(user)
		
		restService.loginWithUser(user, successBlock: { [unowned self] (downloadedUser) in
			
			user.ID = downloadedUser.ID
			
			self.restService.updateCurrentUserFieldsIfNeededWithUser(user, successBlock: successBlock, errorBlock: errorBlock)
			
			}) { [weak self] (error) in
				self?.output.doingSignUpWithUser(user)
				self?.restService.signUpWithUser(user, successBlock: successBlock, errorBlock: errorBlock)
		}
		
	}
	
	
	func cacheUser(user: SVUser) {
		let userData = NSKeyedArchiver.archivedDataWithRootObject(user)
		NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "user")
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	func cachedUser() -> SVUser? {
		if let userData = NSUserDefaults.standardUserDefaults().objectForKey("user") {
			let user = NSKeyedUnarchiver.unarchiveObjectWithData(userData as! NSData) as? SVUser
			return user
		}
		return nil
	}
}