//
//  AuthStoryInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import KeychainSwift

class AuthStoryInteractor: AuthStoryInteractorInput {

    weak var output: AuthStoryInteractorOutput!
	internal weak var restService: RESTServiceProtocol!
	internal weak var callService: CallServiceProtocol!
	
	fileprivate let cachedUserKey = "user"
	
	// In case chat is doing reconnect(for example connect is triggered by QBChat), we can only log in to REST
	//
	var mutableSuccessBlock: ((_ user: SVUser) -> Void)? = nil
	
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
	
	func signUpOrLoginWithUserName(_ userName: String, tags: [String]) {
		callService.addObserver(self)
		
		let login = UIDevice.current.identifierForVendor?.uuidString ?? NSUUID().uuidString
		let password = "zZc64fj13$_1=fx%"
		
		let user = SVUser(id: nil, login: login, password: password, tags: tags)
		user.fullName = userName
		
		if let cachedUser = cachedUser() {
			// update current user instead of creating new one
			if cachedUser.tags != nil {
				user.id = cachedUser.id
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
	func signUpOrLoginWithUserInRESTSimulatenouslyWithChat(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (_ error: Error?) -> Void) {
		
		assert(user.password != nil)
		
		// mutableSuccessBlock will be called and then set to nil after connection established
		mutableSuccessBlock = successBlock
		
		signUpOrLoginWithUser(user, successBlock: { [unowned self] (restUser) in
			
			guard !self.callService.isConnecting else {
				// successBlock will be called later
				return
			}
			guard !self.callService.isConnected else {
				self.mutableSuccessBlock?(restUser)
				self.mutableSuccessBlock = nil
				return
			}
			
			assert(restUser.password != nil)
			assert(restUser.id != nil)
			
			self.callService.connectWithUser(restUser, completion: { (error) in
				if error != nil || !self.callService.isConnected {
					errorBlock(error)
					return
				}
				if user.id == nil {
					user.id = self.callService.currentUser?.id
				}
				self.mutableSuccessBlock?(user)
				self.mutableSuccessBlock = nil
			})
			
		}) { (error) in
			errorBlock(error)
		}
		
		
		// If user ID is not nil, then the user has been logged in previously
		guard user.id != nil else { return }
		guard !callService.isConnecting else {
			return
		}
		
		if restService.isLoggedIn && callService.isConnected {
			self.mutableSuccessBlock?(user)
			self.mutableSuccessBlock = nil
			return
		}
		
		callService.connectWithUser(user) { [unowned self] (error) in
			
			if self.restService.isLoggedIn && self.callService.isConnected {
				self.mutableSuccessBlock?(user)
				self.mutableSuccessBlock = nil
			}
		}
	}
}

extension AuthStoryInteractor: CallServiceObserver {
	func callService(_ callService: CallServiceProtocol, didChangeState state: CallServiceState) {
		NSLog("%@", "AuthStoryInteractor callService didChangeState \(state)")
		
		guard state != .error else {
			output?.didErrorLogin(nil)
			return
		}
		
		guard state == .connected else {
			return
		}
		
		guard let currentUser = callService.currentUser else {
			NSLog("%@", "AuthStoryInteractor callService currentUser nil")
			return
		}
		guard restService.isLoggedIn else {
			NSLog("%@", "AuthStoryInteractor restService isLoggedIn == false")
			return
		}
		
		NSLog("%@", "AuthStoryInteractor callService didChangeState mutableSuccessBlock")
		mutableSuccessBlock?(currentUser)
		mutableSuccessBlock = nil
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
	func signUpOrLoginWithUser(_ user: SVUser, successBlock: @escaping (_ user: SVUser) -> Void, errorBlock: @escaping (Error?) -> Void) {
		output.doingLoginWithUser(user)
		
		restService.loginWithUser(user, successBlock: { [unowned self] (downloadedUser) in
			
			user.id = downloadedUser.id
			
			self.restService.updateCurrentUserFieldsIfNeededWithUser(user, successBlock: successBlock, errorBlock: errorBlock )
			
			}) { [weak self] (error) in
				guard let strongSelf = self else { return }
				strongSelf.output.doingSignUpWithUser(user)
				strongSelf.restService.signUpWithUser(user, successBlock: successBlock, errorBlock: errorBlock )
		}
	}
	
	func cacheUser(_ user: SVUser) {
		assert(user.password != nil)
		assert(user.id != nil)
		let userData = NSKeyedArchiver.archivedData(withRootObject: user)
		
		UserDefaults.standard.set(userData, forKey: cachedUserKey)
		UserDefaults.standard.synchronize()
		
		KeychainSwift().set(userData, forKey: cachedUserKey)
	}
	
	func cachedUser() -> SVUser? {
		
		var userData = UserDefaults.standard.object(forKey: cachedUserKey) as? Data
		if userData == nil {
			userData = KeychainSwift().getData(cachedUserKey)
		}
		if let userData = userData,
			let user = NSKeyedUnarchiver.unarchiveObject(with: userData as Data) as? SVUser {
			assert(user.password != nil)
			assert(user.id != nil)
			return user
		}
		return nil
	}
	
	internal func removeCachedUser() {
		UserDefaults.standard.removeObject(forKey: cachedUserKey)
		UserDefaults.standard.synchronize()

		KeychainSwift().delete(cachedUserKey)
	}
}
