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
	var restService: protocol<RESTServiceProtocol>!
	
	
	// MARK: AuthStoryInteractorInput
	func tryRetrieveCachedUser() {
		if let cachedUser = cachedUser() {
			output.doingLoginWithUser(cachedUser)
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
	
	func signUpOrLoginWithUserName(userName: String, tags: [String]) {
		
		let login = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
		let password = "zZc64fj13$_1=fx%"
		
		let user = SVUser.init(ID: nil, login: login, password: password, tags: tags)
		
		self.signUpOrLoginWithUser(user, successBlock: { (user) in
			user.password = password
			self.output.didLoginUser(user)
			}) { (error) in
				self.output.didErrorLogin(error)
		}
		
	}
	
	private func signUpOrLoginWithUser(user: SVUser, successBlock: ((user: SVUser) -> Void)?, errorBlock: ((NSError?) -> Void)?) {
		
		self.restService.loginWithUser(user, successBlock: successBlock) { [weak self] (error) in
				
				self?.restService.signUpWithUser(user, successBlock: successBlock, errorBlock: errorBlock)
		}
	}
	
}
