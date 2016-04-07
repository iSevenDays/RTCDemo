//
//  AuthStoryInteractorOutput.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol AuthStoryInteractorOutput: class {

	func doingLoginWithUser(user: SVUser)
	func doingSignUpWithUser(user: SVUser)
	
	func didLoginUser(user: SVUser)
	
	/**
	Called when user logined successfuly
	But returned user is nil (this should not happen)
	*/
	func didErrorLogin(error: NSError?)
	
}
