//
//  AuthStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

class AuthStoryInteractor: AuthStoryInteractorInput {

    weak var output: AuthStoryInteractorOutput!
	internal weak var restService: RESTServiceProtocol!
	internal weak var callService: CallServiceProtocol!
	
	// In case chat is doing reconnect(for example connect is triggered by QBChat), we can only log in to REST
	//
	var mutableSuccessBlock: ((user: SVUser) -> Void)? = nil
	
	// MARK: AuthStoryInteractorInput
	func tryLoginWithCachedUser() {
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
		callService.addObserver(self)
		
		let login = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? NSUUID().UUIDString
		let password = "zZc64fj13$_1=fx%"
		
		let user = SVUser(ID: nil, login: login, password: password, tags: tags)
		user.fullName = userName
		
		if let cachedUser = cachedUser() {
			// update current user instead of creating new one
			if cachedUser.tags != nil {
				user.ID = cachedUser.ID
				user.login = cachedUser.login
			}
		}
		
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
		
		// mutableSuccessBlock will be called and then set to nil after connection established
		mutableSuccessBlock = successBlock
		
		signUpOrLoginWithUser(user, successBlock: { [unowned self] (restUser) in
			
			guard !self.callService.isConnecting else {
				// successBlock will be called later
				return
			}
			guard !self.callService.isConnected else {
				self.mutableSuccessBlock?(user: restUser)
				self.mutableSuccessBlock = nil
				return
			}
			
			assert(restUser.password != nil)
			assert(restUser.ID != nil)
			
			self.callService.connectWithUser(restUser, completion: { (error) in
				if error != nil || !self.callService.isConnected {
					errorBlock(error: error)
					return
				}
				
				self.mutableSuccessBlock?(user: user)
				self.mutableSuccessBlock = nil
			})
			
		}) { (error) in
			errorBlock(error: error)
		}
		
		
		// If user ID is not nil, then the user has been logged in previously
		guard user.ID != nil else { return }
		guard !callService.isConnecting else {
			return
		}
		
		if restService.currentUser() != nil && callService.isConnected {
			self.mutableSuccessBlock?(user: user)
			self.mutableSuccessBlock = nil
			return
		}
		
		callService.connectWithUser(user) { [unowned self] (error) in
			
			if self.restService.currentUser() != nil && self.callService.isConnected {
				self.mutableSuccessBlock?(user: user)
				self.mutableSuccessBlock = nil
			}
		}
	}
}

extension AuthStoryInteractor: CallServiceObserver {
	func callService(callService: CallServiceProtocol, didChangeState state: CallServiceState) {
		guard state == .Connected else { return }
		guard let currentUser = callService.currentUser else {
			
			return
		}
		
		if restService.currentUser() != nil {
			mutableSuccessBlock?(user: currentUser)
			mutableSuccessBlock = nil
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
	5. Signup
	6. Signup was successful   -> successBlock
	7. Signup was unsuccessful -> error block
	
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
				guard let strongSelf = self else { return }
				strongSelf.output.doingSignUpWithUser(user)
				strongSelf.restService.signUpWithUser(user, successBlock: successBlock, errorBlock: errorBlock)
		}
	}
	
	
	func cacheUser(user: SVUser) {
		assert(user.password != nil)
		assert(user.ID != nil)
		let userData = NSKeyedArchiver.archivedDataWithRootObject(user)
		let key = "user"
		NSUserDefaults.standardUserDefaults().setObject(userData, forKey: key)
		NSUserDefaults.standardUserDefaults().synchronize()
		
		KeychainSwift().set(userData, forKey: key)
	}
	
	func cachedUser() -> SVUser? {
		let key = "user"
		var userData = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData
		if userData == nil {
			userData = KeychainSwift().getData(key)
		}
		if let userData = userData,
			let user = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as? SVUser {
			assert(user.password != nil)
			assert(user.ID != nil)
			return user
		}
		return nil
	}
}
