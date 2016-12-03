//
//  AuthStoryInteractorInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 27/03/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol AuthStoryInteractorInput {

	func tryLoginWithCachedUser()
	func signUpOrLoginWithUserName(userName: String, tags: [String])
}
